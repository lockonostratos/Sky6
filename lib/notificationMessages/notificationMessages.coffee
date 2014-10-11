@NotificationMessages = {}

NotificationMessages.permissionChanged = (creator) -> "#{creator} đã điều chỉnh phân quyền lại cho bạn!"
NotificationMessages.newMemberJoined = (userName, companyName) -> "Chào mừng #{userName} đã gia nhập #{companyName}!"
NotificationMessages.placeChanged = (creator, place) -> "#{userName} đã chuyển bạn tới #{place}!" #Kho, Chi Nhánh
NotificationMessages.deliveryNotify = (customer, place, value) -> "Có một đơn hàng mới #{value}, tại #{place} đang chờ giao"
NotificationMessages.saleHelper = (creator, value) -> "#{creator} đã bán dùm bạn một đơn hàng có giá trị #{value}"

NotificationMessages.exportNotify = (customer, place, value) -> "Có một đơn hàng mới #{value}, đang chờ xuất kho"
NotificationMessages.managerReturnConfirm = (creator, value) -> "Có một đơn trả hàng #{value} cần duyệt" #Manager, Warehouse, Accounting