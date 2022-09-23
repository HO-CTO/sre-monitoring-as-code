// This file contains shared functions for string formatting

// Capitalises the first letter in each word of the string
// @param string The string being processed
// @returns The string but with first letters capitalised
local capitaliseFirstLetters(string) =
  std.join(' ', std.map(
    function(word) std.asciiUpper(std.substr(word, 0, 1)) + std.substr(word, 1, std.length(word) - 1),
    std.split(string, ' ')
  ));

// File exports
{
  capitaliseFirstLetters(string): capitaliseFirstLetters(string),
}
