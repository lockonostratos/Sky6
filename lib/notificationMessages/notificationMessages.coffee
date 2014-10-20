@NotificationMessages = {}

NotificationMessages.permissionChanged = (creator) -> "#{creator} đã điều chỉnh phân quyền lại cho bạn!"
NotificationMessages.newMemberJoined   = (userName, companyName) -> "Chào mừng #{userName} đã gia nhập #{companyName}!"
NotificationMessages.placeChanged      = (creator, place) -> "#{userName} đã chuyển bạn tới #{place}!" #Kho, Chi Nhánh

NotificationMessages.managerReturnConfirm = (creator, value) -> "Có một đơn trả hàng #{value} cần duyệt" #Manager, Warehouse, Accounting
NotificationMessages.saleHelper       = (creator, orderCode, value) -> "#{creator} đã bán dùm bạn một đơn hàng #{orderCode} có giá trị #{value}"

NotificationMessages.accountingNotify     = (creator, value)               -> "Có một đơn hàng mới #{value} của #{creator}, cần bạn xác nhận đã thu tiền"
#thông báo cho nhân viên bán hàng đơn hàng đã thu tiền
NotificationMessages.sellerByCashier      = (cashier, value)               -> "Đơn bán hàng #{value} của bạn, đã được xác nhận thu tiền bởi #{cashier}"
NotificationMessages.saleCreatorByCashier = (cashier, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận thu tiền bởi #{cashier}"
NotificationMessages.saleSellerByCashier  = (cashier, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận thu tiền bởi #{cashier}"

NotificationMessages.deliveryNotify       = (creator, orderCode, place)    -> "Có một đơn hàng mới #{orderCode} của #{creator}, tại #{place} đang chờ giao"
#thông báo cho nhân viên bán hàng đơn hàng đã được nhận
NotificationMessages.sellerByShipperSelected      = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã được nhận giao bởi #{shipper}"
NotificationMessages.saleCreatorByShipperSelected = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được nhận giao bởi #{shipper}"
NotificationMessages.saleSellerByShipperSelected  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được nhận giao bởi #{shipper}"

NotificationMessages.exportNotify          = (creator, value, place)         -> "Có một đơn hàng mới #{value} của #{creator}, cần bạn xác nhận đã xuất kho"
#thông báo cho nhân viên bán hàng đơn hàng đang được xuất kho
NotificationMessages.sellerByExporter      = (exporter, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã được xác nhận xuất kho bởi #{exporter}"
NotificationMessages.saleCreatorByExporter = (exporter, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận xuất kho bởi #{exporter}"
NotificationMessages.saleSellerByExporter  = (exporter, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận xuất kho bởi #{exporter}"

#thông báo cho nhân viên bán hàng đơn hàng đi giao thất bại (nhập vào kho)
NotificationMessages.sellerByImporter      = (importer, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã được xác nhận xuất kho bởi #{importer}"
NotificationMessages.saleCreatorByImporter = (importer, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận xuất kho bởi #{importer}"
NotificationMessages.saleSellerByImporter  = (importer, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận xuất kho bởi #{importer}"

NotificationMessages.deliveryExport   = (exporter, orderCode, place) -> "Đơn giao hàng #{orderCode} của bạn đã nhận, đã được xác nhận xuất kho bởi #{exporter}"
#thông báo cho nhân viên bán hàng đơn hàng đang đi giao
NotificationMessages.sellerByShipperWorking      = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã bắt đầu đi giao bởi #{shipper}"
NotificationMessages.saleCreatorByShipperWorking = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã bắt đầu đi giao bởi #{shipper}"
NotificationMessages.saleSellerByShipperWorking  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã bắt đầu đi giao bởi #{shipper}"

#thông báo cho nhân viên bán hàng đơn hàng đã giao hàng thành công
NotificationMessages.sellerByDeliverySuccess      = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã giao hàng thành công bởi #{shipper}"
NotificationMessages.saleCreatorByDeliverySuccess = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã giao hàng thành công bởi #{shipper}"
NotificationMessages.saleSellerByDeliverySuccess  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã giao hàng thành công bởi #{shipper}"

#thông báo cho nhân viên bán hàng đơn hàng đã giao hàng thất bại
NotificationMessages.sellerByDeliveryFail      = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã giao hàng thất bại bởi #{shipper}"
NotificationMessages.saleCreatorByDeliveryFail = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã giao hàng thất bại bởi #{shipper}"
NotificationMessages.saleSellerByDeliveryFail  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã giao hàng thất bại bởi #{shipper}"


