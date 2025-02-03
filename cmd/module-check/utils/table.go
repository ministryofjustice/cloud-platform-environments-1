package utils

// output the module inputs
// table format
// func ModuleInputs(pullRequest structs.PullRequests) {
// 	fmt.Printf("Pull Request Details: \n")

// 	prtbl := table.New("Details", "Inputs")
// 	rows := [][]string{
// 		{"Pull Request Title", pullRequest.Title},
// 		{"Pull Request Body", pullRequest.Body},
// 		{"Pull Request Number", fmt.Sprintf("%d", pullRequest.Number)},
// 		{"Pull Request State", pullRequest.State},
// 		{"Pull Request URL", pullRequest.URL},
// 		{"Pull Request Base", pullRequest.Base},
// 		{"Pull Request Head", pullRequest.Head},
// 	}
// 	for _, m := range modules {
// 		if len(m.Approved) > 0 {
// 			rows = append(rows, []string{"Approved Module", strings.Join(m.Approved, ", ")})
// 		}
// 		if len(m.Unapproved) > 0 {
// 			rows = append(rows, []string{"Unapproved Module", strings.Join(m.Unapproved, ", ")})
// 		}
// 	}

// 	prtbl.SetRows(rows)
// 	prtbl.Print()
// }
