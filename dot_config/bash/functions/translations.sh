#!/bin/bash
# Translation Functions

## Spanish - English translations
function ts() {
  input=$1
  trans es:en "$input"
}

## English - Spanish translations
function te() {
  input=$1
  trans en:es "$input"
} 