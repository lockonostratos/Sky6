comments = [
  name: -> 'Phan Ngọc Vinh'
  position: -> 'Chủ xưởng gỗ Vinh Phát (Đắc Lắc)'
  avatar: -> 'a.vinh.jpg'
  comment: -> "Tôi đã tìm hiểu qua nhiều phần mềm quản lý trước khi quyết định sử dụng EDS. Đây là phần mềm tiện dụng
               nhất mà tôi từng biết, tôi rất ấn tượng với giao diện metro, rất đẹp và dễ hiểu. Tôi rất phấn khởi vì
               không cần tốn thời gian để dạy cho nhân viên."
,
  name: -> 'Nguyễn Anh Phương'
  position: -> 'Du học sinh (Mỹ)'
  avatar: -> 'a.phuong.jpg'
  comment: -> "Tôi hiện đang du học ở Mỹ nhưng Công ty của gia đình tại Việt Nam cũng cần quản lý. Vì vậy tôi cần tìm
               một phần mềm có thể giúp tôi kiểm soát việc kinh doanh từ xa. Qua một người bạn giới thiệu, tôi đã ứng
               dụng EDS và rất hài lòng về sự tiện dụng của nó, nhất là khi tôi có thể quản lý công việc kinh doanh từ nước ngoài"
,
  name: -> 'Nguyễn Ngọc Giàu'
  position: -> 'Chủ nhà hàng New Coffee Bar (Mỹ Tho - Tiền Giang)'
  avatar: -> 'c.giau.jpg'
  comment: -> "Tôi vừa quản lý nhà hàng ở Mỹ Tho vừa làm việc tại TP.HCM nên suốt ngày cứ chạy lên chạy xuống, nhiều lúc
               mệt mỏi muốn nghĩ kinh doanh luôn. Nhưng từ khi sử dụng EDS thì mọi chuyện khác hẳn, tôi không cần phải
               di chuyển liên tục nữa vì có thể quản lý nhà hàng từ xa, cứ mở điện thoại lên là làm việc được ngay.
               Bây giờ việc kinh doanh của tôi đã thuận lợi hơn rất nhiều. Trước đây có nằm mơ cũng không nghĩ là làm
               cùng lúc được nhiều việc như vậy."
,
  name: -> 'Nguyễn Thị Ngọc Tuyền'
  position: -> 'Khu du lịch sinh thái (Tiền Giang)'
  avatar: -> 'c.tuyen.jpg'
  comment: -> "Vào những ngày cuối tuần hay dịp lễ Tết, khách đến tham quan rất nhiều, nhiều lúc không thể nào phục vụ
               cho tất cả các khách hàng. Tôi nghĩ là bó tay rồi, cũng không nghĩ là phần mềm gì đó có thể cải thiện
               được chuyện này đâu. Vậy mà công ty Thiên Ban phải làm tôi suy nghĩ lại và cuối cùng tôi quyết định sử
               dụng phần mềm EDS, hệ thống nhắc nhở tự động của EDS giúp chúng tôi chủ động hơn trong việc chăm sóc khách
               hàng, tình hình phàn nàn về chất lượng phục vụ hình như là không còn nữa."
,
  name: -> 'Phạm Minh Hoàng'
  position: -> 'Chủ shop đồng hồ DOHO Replica'
  avatar: -> 'no-avatar.jpg'
  comment: -> "Trước đây, chúng tôi sử dụng excel để quản lý công việc. Nhưng khi quy mô được mở rộng hơn thì mọi việc
               cứ xáo trộn lên, tình trạng thất thoát liên tục xảy ra. Tình hình này làm tôi lo lắng suốt một thời gian,
               tôi đã tìm hiểu nhiều hệ thống quản lý cho đến khi được giới thiệu về hệ thống này. Ngoài việc kiểm soát
               được số liệu hàng hóa, tôi thật sự rất thích hệ thống nhắc nhở tự động, tôi không cần phải ghi nhớ mọi
               thứ nữa, có nhiều thời gian hơn để đi du lịch với gia đình."
,
  name: -> 'Đỗ Thụy Vân Quỳnh'
  position: -> 'Chủ shop thời trang Quỳnh Nhi (Bàu Cát, Tân Bình)'
  avatar: -> 'no-avatar.jpg'
  comment: -> "Lúc trước quần áo nhập về quá nhiều nên chuyện tính nhầm giá bán cho khách hàng xảy ra liên tục.
               Từ khi triển khai EDS, hàng hóa được quản lý rõ ràng hơn, Tôi cũng có nhiều thời gian chăm lo cho gia
               đình hơn. Trong tương lai, tôi dự tính sẽ mở thêm vài chi nhánh nữa, và dĩ nhiên vẫn sẽ áp dụng EDS cho
               mỗi chi nhánh"
]

navigateComment = (step = 1)->
  currentCommentIndex = Session.get('currentCommentPosition')
  console.log currentCommentIndex, comments.length
  currentCommentIndex += step

  if currentCommentIndex >= comments.length
    currentCommentIndex = 0
  else if currentCommentIndex < 0
    currentCommentIndex = comments.length - 1

  Session.set('currentCommentPosition', currentCommentIndex)
  Sky.helpers.animateUsing("#home-comment-wrapper", "fadeIn")

Sky.template.extends Template.merchantTestimonials,
  currentComment: -> comments[Session.get('currentCommentPosition')]
  created: -> Session.set('currentCommentPosition', 0)
  events:
    'click .nextCommand': -> navigateComment()
    'click .previousCommand': -> navigateComment(-1)