Schema.add 'skulls', class Skull
  print: -> console.log @schema
  update: (option, callback = {}) -> @schema.update @id, option, callback