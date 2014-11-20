@NotificationMessages = {}

NotificationMessages.permissionChanged = (creator) -> "#{creator} đã điều chỉnh phân quyền lại cho bạn!"
NotificationMessages.newMemberJoined   = (userName, companyName) -> "Chào mừng #{userName} đã gia nhập #{companyName}!"
NotificationMessages.placeChanged      = (creator, place) -> "#{userName} đã chuyển bạn tới #{place}!" #Kho, Chi Nhánh

NotificationMessages.managerReturnConfirm = (creator, value) -> "Có một đơn trả hàng #{value} cần duyệt" #Manager, Warehouse, Accounting
NotificationMessages.saleHelper       = (creator, orderCode, value) -> "#{creator} đã bán dùm bạn một đơn hàng #{orderCode} có giá trị #{value}"

NotificationMessages.productExpireDate   = (productName, date, place)    -> "Sản phẩm #{productName}, tại kho #{place} sắp hết hạn (còn #{date} ngày)."
NotificationMessages.productAlertQuality = (productName, quality, place) -> "Sản phẩm #{productName}, tại kho #{place} sắp hết hàng (còn #{quality} sản phẩm)."

NotificationMessages.sendAccountingByNewSale  = (creator, orderCode, place)    -> "Có một đơn hàng mới #{orderCode} của #{creator}, cần bạn xác nhận đã thu tiền"
NotificationMessages.sendExporterBySaleExport = (creator, orderCode, place)    -> "Có một đơn hàng mới #{orderCode} của #{creator}, cần bạn xác nhận đã xuất kho"
NotificationMessages.sendShipperByNewDelivery = (creator, orderCode, place)    -> "Có một đơn hàng mới #{orderCode} của #{creator}, tại #{place} đang chờ giao"
NotificationMessages.sendShipperByExport      = (exportName, orderCode, place) -> "Đơn giao hàng #{orderCode} của bạn đã nhận, đã được xác nhận xuất kho bởi #{exportName}"

NotificationMessages.sendNewReturnCreate        = (creator, returnCode, place) -> "Có một đơn trả hàng mới #{returnCode} của #{creator}, tại #{place} đang chờ xác nhận của bạn."
NotificationMessages.sendCreatorByReturnConfirm = (creator, returnCode, place) -> "Đơn trả hàng #{returnCode} của bạn, tại #{place} đã đươc xác nhận bởi #{creator}."
NotificationMessages.sendCreatorByReturnDestroy = (creator, returnCode, place) -> "Đơn trả hàng #{returnCode} của bạn, tại #{place} đã bị hủy bởi #{creator}."

NotificationMessages.sendNewInventoryCreate        = (creator, returnCode, place) -> "Có một đơn kiểm kho mới #{returnCode} của #{creator}, tại #{place} đang chờ xác nhận của bạn."
NotificationMessages.sendCreatorByInventoryConfirm = (creator, returnCode, place) -> "Đơn kiểm kho #{returnCode} của bạn, tại #{place} đã đươc xác nhận bởi #{creator}."
NotificationMessages.sendCreatorByInventoryDestroy = (creator, returnCode, place) -> "Đơn kiểm kho #{returnCode} của bạn, tại #{place} đã bị hủy bởi #{creator}."


NotificationMessages.sendByCashier                    = (cashier, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã được xác nhận thu tiền bởi #{cashier}"
NotificationMessages.sendCreatorSaleByCashier         = (cashier, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận thu tiền bởi #{cashier}"
NotificationMessages.sendSellerSaleByCashier          = (cashier, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận thu tiền bởi #{cashier}"

NotificationMessages.sendByExporter                   = (exporter, orderCode)          -> "Đơn bán hàng #{orderCode} của bạn, đã được xác nhận xuất kho bởi #{exporter}"
NotificationMessages.sendCreatorSaleByExporter        = (exporter, seller, orderCode)  -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận xuất kho bởi #{exporter}"
NotificationMessages.sendSellerSaleByExporter         = (exporter, cretator, orderCode)-> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận xuất kho bởi #{exporter}"

NotificationMessages.sendByImporter                   = (importer, orderCode)          -> "Đơn bán hàng #{orderCode} của bạn, đã được xác nhận nhập kho bởi #{importer}"
NotificationMessages.sendCreatorSaleByImporter        = (importer, seller, orderCode)  -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được xác nhận nhập kho bởi #{importer}"
NotificationMessages.sendSellerSaleByImporter         = (importer, cretator, orderCode)-> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được xác nhận nhập kho bởi #{importer}"

NotificationMessages.sendByShipperSelected            = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã được nhận giao bởi #{shipper}"
NotificationMessages.sendCreatorSaleByShipperSelected = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã được nhận giao bởi #{shipper}"
NotificationMessages.sendSellerSaleByShipperSelected  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã được nhận giao bởi #{shipper}"

NotificationMessages.sendByShipperWorking             = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã bắt đầu đi giao bởi #{shipper}"
NotificationMessages.sendCreatorSaleByShipperWorking  = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã bắt đầu đi giao bởi #{shipper}"
NotificationMessages.sendSellerSaleByShipperWorking   = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã bắt đầu đi giao bởi #{shipper}"

NotificationMessages.sendByDeliverySuccess            = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã giao hàng thành công bởi #{shipper}"
NotificationMessages.sendCreatorSaleByDeliverySuccess = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã giao hàng thành công bởi #{shipper}"
NotificationMessages.sendSellerSaleByDeliverySuccess  = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã giao hàng thành công bởi #{shipper}"

NotificationMessages.sendByDeliveryFail               = (shipper, orderCode)           -> "Đơn bán hàng #{orderCode} của bạn, đã giao hàng thất bại bởi #{shipper}"
NotificationMessages.sendCreatorSaleByDeliveryFail    = (shipper, seller, orderCode)   -> "Đơn bán hàng #{orderCode} được bạn tạo dùm cho #{seller}, đã giao hàng thất bại bởi #{shipper}"
NotificationMessages.sendSellerSaleByDeliveryFail     = (shipper, cretator, orderCode) -> "Đơn bán hàng #{orderCode} được tạo dùm bởi #{cretator}, đã giao hàng thất bại bởi #{shipper}"
