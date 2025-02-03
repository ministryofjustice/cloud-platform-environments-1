package structs

// struct to hold ecr module data from terraform module
// this data if stored in the struct to allow the data to be queried for self approval
// data will be pulled in for a pull request and checked against the approvedModules map
type ServiceAccount struct {
	Source string `json:"source"`
}
