Books = new Meteor.Collection "books"
Lists = new Meteor.Collection "lists"
Todos = new Meteor.Collection "todos"



Meteor.startup ->
  Books.remove({})
  Lists.remove({})
  Todos.remove({})
  timestamp = (new Date()).getTime()
  if Lists.find().count() is 0
    data = [
      {
        name: "Meteor Principles"
        contents: [
          [
            "Data on the Wire"
            "Simplicity"
            "Better UX"
            "Fun"
          ]
          [
            "One Language"
            "Simplicity"
            "Fun"
          ]
          [
            "Database Everywhere"
            "Simplicity"
          ]
          [
            "Latency Compensation"
            "Better UX"
          ]
          [
            "Full Stack Reactivity"
            "Better UX"
            "Fun"
          ]
          [
            "Embrace the Ecosystem"
            "Fun"
          ]
          [
            "Simplicity Equals Productivity"
            "Simplicity"
            "Fun"
          ]
        ]
      }
      {
        name: "Languages"
        contents: [
          [
            "Lisp"
            "GC"
          ]
          [
            "C"
            "Linked"
          ]
          [
            "C++"
            "Objects"
            "Linked"
          ]
          [
            "Python"
            "GC"
            "Objects"
          ]
          [
            "Ruby"
            "GC"
            "Objects"
          ]
          [
            "JavaScript"
            "GC"
            "Objects"
          ]
          [
            "Scala"
            "GC"
            "Objects"
          ]
          [
            "Erlang"
            "GC"
          ]
          [
            "6502 Assembly"
            "Linked"
          ]
        ]
      }
      {
        name: "Favorite Scientists"
        contents: [
          [
            "Ada Lovelace"
            "Computer Science"
          ]
          [
            "Grace Hopper"
            "Computer Science"
          ]
          [
            "Marie Curie"
            "Physics"
            "Chemistry"
          ]
          [
            "Carl Friedrich Gauss"
            "Math"
            "Physics"
          ]
          [
            "Nikola Tesla"
            "Physics"
          ]
          [
            "Claude Shannon"
            "Math"
            "Computer Science"
          ]
        ]
      }
    ]

    i = 0
    while i < data.length
      list_id = Lists.insert(name: data[i].name)
      j = 0
      while j < data[i].contents.length
        info = data[i].contents[j]
        Todos.insert
          list_id: list_id
          text: info[0]
          timestamp: timestamp
          tags: info.slice(1)

        timestamp += 1
        j++
      i++


#  if Merchants.find().count() is 0
#    mer_id = Merchants.insert
#                name: 'Nhà Phân Phối Huỳnh Châu'
#                createdAt: timestamp
#                updatedAt: timestamp
#    ware_id = Warehouses.insert
#                merchantId: mer_id
#                name: 'Chi Nhanh Tân Bình'
#                location: '32 - Ni Sư Huỳnh Liên, P.10, Q.Tân Bình, Tp-HCM'
#                createdAt: timestamp
#                updatedAt: timestamp
#  if Skulls.find().count() is 0
#      Skulls.insert
#        merchantId: mer_id
#        skull_01: ['Lon', 'Thùng']
#        skull_02: ['0.12L','0.7L', '0.8L', '1L', '4L' ]
#
#  if Providers.find().count() is 0
#    Providers.insert
#              merchantId: mer_id
#              name: 'Dầu Nhớt BP'
#              createdAt: timestamp
#              updatedAt: timestamp






  return


