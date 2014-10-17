comments = [
  ownerName: -> '1'
  ownerPosition: -> '1'
  ownerAvatar: -> '1'
  comment: -> "Hệ thống này là trực quan nhất so với tất cả những sản phẩm mà tôi đã từng sử dụng, tôi bị ấn tượng mạnh
               bởi giao diện metro. Chúng tôi thậm chí không cần tốn thời gian training nhân viên vì nó quá dễ hiểu!"
,
  ownerName: -> '2'
  ownerPosition: -> '2'
  ownerAvatar: -> '2'
  comment: -> "Cửa hàng của tôi khá lớn, chúng tôi đã xử dụng excel rất tốt trước đó, cho đến khi tôi được giới thiệu về
               hệ thống này. Ngoài việc kiểm soát được số liệu hàng hóa tôi bị ấn tượng bởi hệ thống nhắc nhở tôi không
               cần phải ghi nhớ mọi thứ nữa, có nhiều thời gian hơn để đi du lịch"
,
  ownerName: -> '3'
  ownerPosition: -> '3'
  ownerAvatar: -> '3'
  comment: -> "Tôi là Quỳnh, chủ cửa hàng thời trang Quỳnh Nhi chuyên kinh doanh quần áo xách tay (Bàu Cát, Tân Bình).
              Lúc trước quần áo nhập về quá nhiều, có đôi lúc tính nhầm giá bán cho khách hàng. Từ khi triển khai EDS,
              hàng hóa được quản lý rõ ràng hơn, Tôi cũng có nhiều thời gian chăm lo cho gia đình hơn. Trong tương lai,
              tôi dự tính sẽ mở thêm vài chi nhánh nữa, và dĩ nhiên vẫn sẽ áp dụng EDS cho mỗi chi nhánh"
,
  ownerName: -> '4'
  ownerPosition: -> '4'
  ownerAvatar: -> '4'
  comment: -> "Anh Phương, một du học sinh tại Mỹ: Tôi hiện đang du học ở Mỹ nhưng Công ty của gia đình tại Việt Nam
               cũng cần tôi quản lý. Vì vậy tôi cần tìm một phần mềm có thể giúp tôi kiểm soát việc kinh doanh từ xa.
               Qua một người bạn giới thiệu, tôi đã ứng dụng EDS, tôi rất hài lòng về sự tiện dụng của nó, nhất là khi
               tôi có thể quản lý công việc kinh doanh từ nước ngoài"
,
  ownerName: -> '5'
  ownerPosition: -> '5'
  ownerAvatar: -> '5'
  comment: -> "Chị Giàu, chủ nhà hàng New Coffee Bar tại Mỹ Tho, Tiền Giang: đặc thù công việc của tôi là phải di chuyển
               giữa Tiền Giang và Thành phố Hồ Chí Minh, nên khó khăn cho việc quản lý nhà hàng ở quê nhà, tôi cần tìm
               một giải pháp phù hợp. Do đó tôi quyết định sử dụng EDS, từ đó việc quản lý kinh doanh đã thuận lợi và
               chuyên nghiệp hơn rất nhiều"
,
  ownerName: -> 'Tuyền'
  ownerPosition: -> 'Khu du lịch sinh thái Tiền Giang'
  ownerAvatar: -> '6'
  comment: -> "Vào những ngày cuối tuần hay dịp lễ Tết, khách đến tham quan khu du lịch của chúng tôi rất nhiều, đôi khi
               không thể nào phục vụ tốt tất cả nhu cầu của khách hàng. Nhưng từ khi triển khai EDS, hệ thống nhắc nhở
               tự động giúp chúng tôi chủ động hơn trong việc chăm sóc khách hàng tôi đã được chăm sóc tốt hơn rất nhiều"
]

navigateNextComment = ->
  currentCommentIndex = Session.get('currentCommentPosition')
  if currentCommentIndex + 1 >= comments.length
    currentCommentIndex = 0
  else
    currentCommentIndex++
  Session.set('currentCommentPosition', currentCommentIndex)

Sky.template.extends Template.merchantTestimonials,
  currentComment: -> comments[Session.get('currentCommentPosition')]
  created: -> Session.set('currentCommentPosition', 0)
  events:
    'click .nextCommand': -> navigateNextComment()