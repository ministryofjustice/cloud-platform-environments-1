package authenticate

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/metrics/pkg/client/clientset/versioned"
)

// GitHubClient takes a GitHub personal access key as a string and builds
// and returns a GitHub client to the caller.
func GitHubClient(token string) (*github.Client, error) {
	if token == "" {
		return nil, errors.New("personal access token is empty, unable to create GitHub client")
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: token,
		},
	)
	tc := oauth2.NewClient(ctx, ts)

	return github.NewClient(tc), nil
}

// KubeConfigFromS3Bucket takes four arguments:
// bucket: The name of the s3 bucket to grab your kubeconfig file from.
// s3FileName: The name of the kubeconfig file in the bucket.
// region: The AWS region of the bucket.
// It will create a file in ~/.kube/config
func KubeConfigFromS3Bucket(bucket, s3FileName, region string) error {
	buff := &aws.WriteAtBuffer{}
	session, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return err
	}

	downloader := s3manager.NewDownloader(session)

	numBytes, err := downloader.Download(buff, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(s3FileName),
	})

	if err != nil {
		return err
	}
	if numBytes < 1 {
		return fmt.Errorf("error the kubecfg file downloaded is empty and must have failed")
	}

	data := buff.Bytes()
	err = ioutil.WriteFile(filepath.Join("/", "tmp", "config"), data, 0644)
	if err != nil {
		return err
	}

	return nil
}

// CreateClientFromConfigFile takes a kubeconfig file and a cluster context i.e. live-1.cloud-platform.service.justice.gov.uk
// and returns a kubernetes clientset ready to use with the cluster in your context.
func CreateClientFromConfigFile(configFile, clusterCtx string) (clientset *kubernetes.Clientset, err error) {

	client, err := NewConfigFromContext(configFile, clusterCtx)

	clientset, _ = kubernetes.NewForConfig(client)
	if err != nil {
		return nil, err
	}

	return
}

// KubeClientFromConfig takes a kubeconfig file and a cluster context i.e. live-1.cloud-platform.service.justice.gov.uk
// and returns a kubernetes clientset ready to use with the cluster in your context.
func CreateMetricsClientFromConfigFile(configFile, clusterCtx string) (clientset *versioned.Clientset, err error) {

	client, err := NewConfigFromContext(configFile, clusterCtx)

	clientset, _ = versioned.NewForConfig(client)
	if err != nil {
		return nil, err
	}

	return
}

func NewConfigFromContext(configFile, clusterCtx string) (*rest.Config, error) {

	return clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: configFile},
		&clientcmd.ConfigOverrides{
			CurrentContext: clusterCtx,
		}).ClientConfig()
}

// CreateClientFromS3Bucket takes the bucket name, a config file, a region and a the context of a cluster and creates
// i.e. live-1.cloud-platform.service.justice.gov.uk and calls two other functions in this package to return a client
// Kubernetes clientset.
func CreateClientFromS3Bucket(bucket, s3FileName, region, clusterCtx string) (clientset *kubernetes.Clientset, err error) {
	configFileLocation := filepath.Join("/", "tmp", "config")
	err = KubeConfigFromS3Bucket(bucket, s3FileName, region)
	if err != nil {
		return nil, err
	}

	clientset, err = CreateClientFromConfigFile(configFileLocation, clusterCtx)
	if err != nil {
		return nil, err
	}

	return
}

// SwitchContextFromConfigFile takes a kubeconfig file and a cluster context i.e. live-1/manager/live
// and set current context, which is useful to switch context to multiple clusters.
func SwitchContextFromConfigFile(clusterCtx, kubeconfigPath string) error {
	kubeconfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: kubeconfigPath},
		&clientcmd.ConfigOverrides{
			CurrentContext: clusterCtx,
		})
	config, err := kubeconfig.RawConfig()
	if err != nil {
		return fmt.Errorf("error getting RawConfig: %w", err)
	}

	if config.Contexts[clusterCtx] == nil {
		return fmt.Errorf("context %s doesn't exists", clusterCtx)
	}

	config.CurrentContext = clusterCtx
	err = clientcmd.ModifyConfig(clientcmd.NewDefaultPathOptions(), config, true)
	if err != nil {
		return fmt.Errorf("error ModifyConfig: %w", err)
	}

	return nil
}

// SwitchContextFromS3Bucket takes the bucket name, a config file, a region and a the context of a cluster
// i.e. live/manager/live-1, and set current context in the config file.
func SwitchContextFromS3Bucket(bucket, s3FileName, region, clusterCtx string) (err error) {
	kubeconfigPath := filepath.Join("/", "tmp", "config")
	err = KubeConfigFromS3Bucket(bucket, s3FileName, region)
	if err != nil {
		return err
	}

	err = SwitchContextFromConfigFile(clusterCtx, kubeconfigPath)
	if err != nil {
		return err
	}

	return nil
}
