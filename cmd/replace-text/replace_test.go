package main

import "testing"

func Test_validateFlags(t *testing.T) {
	type args struct {
		o string
		r string
		d string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		// TODO: Add test cases.
		{
			name: "original string cannot be empty",
			args: args{
				o: "",
				r: "replacement",
				d: "dir",
			},
			wantErr: true,
		},
		{
			name: "replacement string cannot be empty",
			args: args{
				o: "original",
				r: "",
				d: "dir",
			},
			wantErr: true,
		},
		{
			name: "directory cannot be empty",
			args: args{
				o: "original",
				r: "replacement",
				d: "",
			},
			wantErr: true,
		},
		{
			name: "all strings are not empty",
			args: args{
				o: "original",
				r: "replacement",
				d: "dir",
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := validateFlags(tt.args.o, tt.args.r, tt.args.d); (err != nil) != tt.wantErr {
				t.Errorf("validateFlags() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
