/**
 * Takes a string as input and splits it into an object with key-value pairs.
 * @param labelString The input string
 * @param tokenDelimiter The delimiter separating key value pairs.
 * @param keyValueDelimiter The delimiter separating keys from values.
 */
export const splitLabels = (
  labelString,
  tokenDelimiter = ",",
  keyValueDelimiter = "="
) => {
  const result = {};
  const input = labelString.trim();

  if (input.length === 0) {
    return result;
  }

  const tokens = input.split(tokenDelimiter);
  for (let token in tokens) {
    const [k, v] = tokens[token].split(keyValueDelimiter);
    result[k.trim()] = v.trim();
  }

  return result;
};
