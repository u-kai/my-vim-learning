package my-vim-learning_test

import "testing"

func TestHoge(t *testing.T) {
    tests := []struct {
        name string
    }{
        {
        },
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // TODO: テストコードを書く
        })
    }
}

