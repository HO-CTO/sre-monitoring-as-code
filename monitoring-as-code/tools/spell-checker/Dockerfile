FROM node:18-alpine

WORKDIR /app

RUN yarn global add spellchecker-cli

COPY .spellcheckerrc.yaml .
COPY dictionary.txt .

CMD [ "spellchecker" ]