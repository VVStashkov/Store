# Поднятие БД
```shell
docker-compose up -d
docker ps
 
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                             NAMES
087f9441cf92   mongo:8   "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes   0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp   mongodb-mongodb-1

docker exec -it <container_id> mongosh -u root -p root

use musicDB
```
# Выполнение задания
## Создание коллекций 
создаются автоматически
## наполнение данными
запрос
```js
db.artists.insertMany([
  {
    _id: ObjectId("67b1c3541c055965b0bb0b01"),
    name: "Imagine Dragons",
    genre: "Rock",
    formed: 2008,
    members: ["Dan Reynolds", "Wayne Sermon", "Ben McKee", "Daniel Platzman"]
  },
  {
    _id: ObjectId("67b1c3541c055965b0bb0b02"),
    name: "Dua Lipa",
    genre: "Pop",
    formed: 2015,
    members: ["Dua Lipa"]
  }
]);
```
ответ
```shell
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('67b1c3541c055965b0bb0b01'),
    '1': ObjectId('67b1c3541c055965b0bb0b02')
  }
}
```

запрос
```js
db.tracks.insertMany([
  {
    title: "Believer",
    durationMs: 204000,
    artistId: ObjectId("67b1c3541c055965b0bb0b01"),
    album: "Evolve",
    metadata: {
      bpm: 125,
      key: "G minor",
      explicit: false
    },
    tags: ["alternative", "rock"]
  },
  {
    title: "Levitating",
    durationMs: 203000,
    artistId: ObjectId("67b1c3541c055965b0bb0b02"),
    album: "Future Nostalgia",
    metadata: {
      bpm: 103,
      key: "F minor",
      explicit: false
    },
    tags: ["pop", "disco"]
  },
  {
    title: "Radioactive",
    durationMs: 186000,
    artistId: ObjectId("67b1c3541c055965b0bb0b01"),
    album: "Night Visions",
    metadata: {
      bpm: 136,
      key: "A minor",
      explicit: false
    },
    tags: ["alternative", "electronic"]
  }
]);
```
ответ
```shell
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('69fa859162526377b244ba89'),
    '1': ObjectId('69fa859162526377b244ba8a'),
    '2': ObjectId('69fa859162526377b244ba8b')
  }
}
```
запрос 
```js
db.playlists.insertMany([
    {
        name: "Rock Hits",
        userId: ObjectId("67b1c3541c055965b0bb0b10"),
        tracks: [
            ObjectId("69fa859162526377b244ba89"),
            ObjectId("69fa859162526377b244ba8b")
        ],
        settings: {
            isPublic: true,
            allowComments: false,
            sortOrder: "byArtist"
        },
        createdAt: new Date()
    },
    {
        name: "Pop Party",
        userId: ObjectId("67b1c3541c055965b0bb0b11"),
        tracks: [
            ObjectId("69fa859162526377b244ba8a")
        ],
        settings: {
            isPublic: false,
            allowComments: true,
            sortOrder: "byTitle"
        },
        createdAt: new Date()
    }
]);
```

ответ
```text
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('69fa88f37eb9d818a944ba8b'),
    '1': ObjectId('69fa88f37eb9d818a944ba8c')
  }
}
```

## запросы
треки с bpm(удары в минуту) больше 120
```js
db.tracks.find({ "metadata.bpm": { $gt: 120 } })
```
```js
[
  {
    _id: ObjectId('69fa859162526377b244ba89'),
    title: 'Believer',
    durationMs: 204000,
    artistId: ObjectId('67b1c3541c055965b0bb0b01'),
    album: 'Evolve',
    metadata: { bpm: 125, key: 'G minor', explicit: false },
    tags: [ 'alternative', 'rock' ]
  },
  {
    _id: ObjectId('69fa859162526377b244ba8b'),
    title: 'Radioactive',
    durationMs: 186000,
    artistId: ObjectId('67b1c3541c055965b0bb0b01'),
    album: 'Night Visions',
    metadata: { bpm: 136, key: 'A minor', explicit: false },
    tags: [ 'alternative', 'electronic' ]
  }
]
```
запрос с проекцией 
```js
db.tracks.find({}, { title: 1, album: 1, _id: 0 })
```
```js
[
  { title: 'Believer', album: 'Evolve' },
  { title: 'Levitating', album: 'Future Nostalgia' },
  { title: 'Radioactive', album: 'Night Visions' }
]
```
update запрос, добавление участника
```js
db.artists.updateOne(
  { name: "Imagine Dragons" },
  { $push: { members: "Andrew Tolman" } }
)
```
```shell
{
    acknowledged: true,
        insertedId: null,
        matchedCount: 1,
        modifiedCount: 1,
        upsertedCount: 0
}
```
проверка 
```shell
musicDB> db.artists.find({name : "Imagine Dragons"})
[
  {
    _id: ObjectId('67b1c3541c055965b0bb0b01'),
    name: 'Imagine Dragons',
    genre: 'Rock',
    formed: 2008,
    members: [
      'Dan Reynolds',
      'Wayne Sermon',
      'Ben McKee',
      'Daniel Platzman',
      'Andrew Tolman'                                                                                                                                                               
    ]
  }
]
```
update запрос
```js
db.tracks.updateMany(
  { "metadata.explicit": false },
  { $set: { rating: 5 } }
)
```
```shell
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 3,
  modifiedCount: 3,
  upsertedCount: 0                                                                                                                                                                  
}
```
проверка

```shell
musicDB> db.tracks.find({})
[
  {
    _id: ObjectId('69fa859162526377b244ba89'),
    title: 'Believer',
    durationMs: 204000,
    artistId: ObjectId('67b1c3541c055965b0bb0b01'),
    album: 'Evolve',
    metadata: { bpm: 125, key: 'G minor', explicit: false },
    tags: [ 'alternative', 'rock' ],
    rating: 5                                                                                                                                                                       
  },
  {
    _id: ObjectId('69fa859162526377b244ba8a'),
    title: 'Levitating',
    durationMs: 203000,
    artistId: ObjectId('67b1c3541c055965b0bb0b02'),
    album: 'Future Nostalgia',
    metadata: { bpm: 103, key: 'F minor', explicit: false },
    tags: [ 'pop', 'disco' ],
    rating: 5                                                                                                                                                                       
  },
  {
    _id: ObjectId('69fa859162526377b244ba8b'),
    title: 'Radioactive',
    durationMs: 186000,
    artistId: ObjectId('67b1c3541c055965b0bb0b01'),
    album: 'Night Visions',
    metadata: { bpm: 136, key: 'A minor', explicit: false },
    tags: [ 'alternative', 'electronic' ],
    rating: 5                                                                                                                                                                       
  }
]
```

запрос с агрегацией
```js
db.tracks.aggregate([
  {
    $lookup: {
      from: "artists",
      localField: "artistId",
      foreignField: "_id",
      as: "artistInfo"
    }
  },
  { $unwind: "$artistInfo" },
  {
    $group: {
      _id: "$artistInfo.name",
      totalDurationSec: { $sum: { $divide: ["$durationMs", 1000] } },
      trackCount: { $count: {} }
    }
  },
  { $sort: { totalDurationSec: -1 } }
])
```
ответ
```shell
[
  { _id: 'Imagine Dragons', totalDurationSec: 390, trackCount: 2 },
  { _id: 'Dua Lipa', totalDurationSec: 203, trackCount: 1 }
]
```