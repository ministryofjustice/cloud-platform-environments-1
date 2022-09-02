package main

import (
	"reflect"
	"testing"
)

func TestNewPullRequest(t *testing.T) {
	type args struct {
		branch string
		number string
	}
	tests := []struct {
		name string
		args args
		want *pullRequest
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := NewPullRequest(tt.args.branch, tt.args.number); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("NewPullRequest() = %v, want %v", got, tt.want)
			}
		})
	}
}
