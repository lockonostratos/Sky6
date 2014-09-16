Schema.add 'userProfiles', class UserProfile
  set: (options) -> @schema.update(@id, {$set: options})