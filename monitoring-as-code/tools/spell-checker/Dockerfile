FROM node:18-alpine

WORKDIR /app

RUN yarn global add spellchecker-cli

CMD [ "spellchecker", "--files", "'**/*.md'","'docs/**/*.md.erb'" ]