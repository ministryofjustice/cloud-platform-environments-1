package structs

type PullRequests struct {
	Title  string `json:"title"`
	Body   string `json:"body"`
	Number int    `json:"number"`
	State  string `json:"state"`
	URL    string `json:"url"`
	Base   string `json:"base"`
	Head   string `json:"head"`
}
