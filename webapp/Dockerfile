FROM node:alpine
WORKDIR /app
COPY package.json ./
RUN npm install
EXPOSE 4502
ENTRYPOINT ["npm", "run"]
CMD ["dev"]
