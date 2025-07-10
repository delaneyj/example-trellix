```sh
npm i
npx prisma migrate dev
npm run dev
```

with Docker
```sh
docker build -t remixtrellix . 
docker run -it -p 3000:3000 remixtrellix
```

export DATABASE_URL="file:./test.sqlite'