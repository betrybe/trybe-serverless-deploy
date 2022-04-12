from node:14-alpine

RUN apk add bash
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O yq \
  && chmod +x yq
RUN npm i -g --production serverless@3.12.0

COPY template.yaml template.yaml
COPY entrypoint.sh entrypoint.sh

CMD ["./entrypoint.sh"]
