// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get name_main => 'Local';

  @override
  String get hint_name => 'Họ và tên';

  @override
  String get hint_password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get forgot_password => 'Quên mật khẩu?';

  @override
  String get create_account_text => 'Tạo tài khoản cho người mới';

  @override
  String get register_prompt => 'Bạn đã có tài khoản? Đăng nhập';

  @override
  String get name_label => 'Họ và tên';

  @override
  String get email_label => 'Email';

  @override
  String get confirm_password => 'Nhập lại mật khẩu';

  @override
  String get register_success => 'Đăng ký thành công';

  @override
  String get hint_email => 'Email';

  @override
  String get login_error => 'Không thể đăng nhập. Vui lòng thử lại.';

  @override
  String get register_error => 'Không thể đăng ký. Vui lòng thử lại.';

  @override
  String get password_mismatch => 'Mật khẩu không khớp';

  @override
  String get email_required => 'Vui lòng nhập email';

  @override
  String get password_required => 'Vui lòng nhập mật khẩu';

  @override
  String get email_invalid => 'Email không hợp lệ';

  @override
  String get name_required => 'Vui lòng nhập họ và tên';

  @override
  String get password_too_short => 'Mật khẩu tối thiểu 6 ký tự';

  @override
  String get confirm_password_required => 'Vui lòng nhập lại mật khẩu';

  @override
  String get login_success => 'Đăng nhập thành công';

  @override
  String get login_first => 'Vui lòng đăng nhập để đăng bài';

  @override
  String get video_not_supported => 'Hiện chưa hỗ trợ đăng video';

  @override
  String get create_post_hint => 'Bạn đang nghĩ gì?';

  @override
  String get create_post_title => 'Tạo bài viết';

  @override
  String get cancel => 'Hủy';

  @override
  String get post => 'Đăng';

  @override
  String get unknown => 'Không xác định';

  @override
  String get comments => 'Bình luận';

  @override
  String get language_english => 'Tiếng Anh';

  @override
  String get language_vietnamese => 'Tiếng Việt';

  @override
  String get create_post_error => 'Không thể đăng bài. Vui lòng thử lại.';

  @override
  String get privacy_public => 'Công khai';

  @override
  String get privacy_friends => 'Bạn bè';

  @override
  String get privacy_private => 'Chỉ mình tôi';

  @override
  String get photo => 'Ảnh';

  @override
  String get video => 'Video';

  @override
  String get tag_people => 'Gắn thẻ bạn bè';

  @override
  String get add_location => 'Địa điểm';

  @override
  String get feeling_activity => 'Cảm xúc/hoạt động';

  @override
  String get create_event => 'Tạo sự kiện';

  @override
  String get create_group_title => 'Tạo nhóm';

  @override
  String get create_group_button => 'Tạo';

  @override
  String get create_group_name_hint => 'Tên nhóm';

  @override
  String get create_group_search_hint => 'Tìm kiếm bạn bè';

  @override
  String get create_group_failed => 'Không thể tạo nhóm.';

  @override
  String get create_post_require_media => 'Vui lòng nhập nội dung hoặc chọn ảnh/video trước khi đăng.';

  @override
  String create_post_image_limit(int count) {
    return 'Bạn chỉ có thể chọn tối đa $count ảnh.';
  }

  @override
  String create_post_video_limit(int count) {
    return 'Bạn chỉ có thể chọn tối đa $count video.';
  }

  @override
  String get search_title => 'Tìm kiếm';

  @override
  String get search_hint => 'Tìm người dùng';

  @override
  String get search_no_results => 'Không tìm thấy người dùng';

  @override
  String get search_error => 'Không thể tìm kiếm người dùng. Vui lòng thử lại.';

  @override
  String get search_min_chars => 'Vui lòng nhập tối thiểu 2 ký tự';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_search => 'Tìm kiếm cài đặt';

  @override
  String get settings_account_center => 'TRUNG TÂM TÀI KHOẢN';

  @override
  String get settings_help_feedback => 'TRỢ GIÚP VÀ PHẢN HỒI';

  @override
  String get settings_options => 'TÙY CHỌN';

  @override
  String get settings_edit_profile => 'Chỉnh sửa hồ sơ';

  @override
  String get settings_edit_profile_desc => 'Cập nhật tên, địa chỉ và thông tin cá nhân';

  @override
  String get settings_contact => 'Cập nhật liên hệ';

  @override
  String get settings_contact_desc => 'Quản lý các nền tảng mạng xã hội của bạn';

  @override
  String get settings_security => 'Bảo mật tài khoản';

  @override
  String get settings_security_desc => 'Thay đổi mật khẩu và bảo mật tài khoản';

  @override
  String get settings_feedback => 'Gửi phản hồi';

  @override
  String get settings_feedback_desc => 'Chia sẻ ý kiến và đề xuất của bạn';

  @override
  String get settings_language => 'Ngôn ngữ';

  @override
  String get settings_language_desc => 'Thay đổi ngôn ngữ hiển thị';

  @override
  String get settings_logout => 'Đăng xuất';

  @override
  String get settings_logout_desc => 'Đăng xuất khỏi tài khoản hiện tại';

  @override
  String get settings_logout_confirm_title => 'Đăng xuất';

  @override
  String get settings_logout_confirm_message => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get common_cancel => 'Hủy';

  @override
  String get common_confirm => 'Xác nhận';

  @override
  String get common_save => 'Lưu';

  @override
  String get common_saving => 'Đang lưu...';

  @override
  String get profile_title => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_display_name => 'Tên hiển thị';

  @override
  String get profile_display_name_hint => 'Nhập tên của bạn';

  @override
  String get profile_phone => 'Số điện thoại';

  @override
  String get profile_phone_hint => 'Nhập số điện thoại';

  @override
  String get profile_address => 'Địa chỉ';

  @override
  String get profile_address_hint => 'Số nhà, đường, thành phố';

  @override
  String get profile_save_success => 'Đã lưu thay đổi hồ sơ';

  @override
  String get profile_phone_invalid => 'Số điện thoại không hợp lệ (VD: 098xxxxxxx)';

  @override
  String get contact_title => 'Cập nhật liên hệ';

  @override
  String get contact_save_success => 'Đã lưu thông tin liên hệ';

  @override
  String get security_title => 'Bảo mật tài khoản';

  @override
  String get security_current_password => 'Mật khẩu hiện tại';

  @override
  String get security_new_password => 'Mật khẩu mới';

  @override
  String get security_confirm_new_password => 'Nhập lại mật khẩu mới';

  @override
  String get security_password_mismatch => 'Mật khẩu mới không khớp';

  @override
  String get security_save_success => 'Đã đổi mật khẩu thành công';

  @override
  String get language_title => 'Ngôn ngữ';

  @override
  String get language_vi => 'Tiếng Việt';

  @override
  String get language_en => 'English';

  @override
  String get language_save_success => 'Đã cập nhật ngôn ngữ. Khởi động lại nếu chưa đổi.';

  @override
  String language_save_failed(Object error) {
    return 'Không thể cập nhật ngôn ngữ: $error';
  }

  @override
  String get feedback_title => 'Phản hồi';

  @override
  String get feedback_hint => 'Hãy cho chúng tôi biết ý kiến của bạn...';

  @override
  String get feedback_optional_email => 'Email liên hệ (tùy chọn)';

  @override
  String get feedback_sent => 'Đã gửi phản hồi. Cảm ơn bạn!';

  @override
  String get feedback_send => 'Gửi phản hồi';

  @override
  String get feedback_sending => 'Đang gửi...';

  @override
  String get feedback_required => 'Nội dung không được để trống';

  @override
  String feedback_failed(Object error) {
    return 'Không thể gửi phản hồi: $error';
  }

  @override
  String get profile_feed_empty => 'Chưa có bài viết nào để hiển thị.';

  @override
  String get profile_login_required_title => 'Bạn chưa đăng nhập';

  @override
  String get profile_login_required_body => 'Vui lòng đăng nhập để xem trang cá nhân của bạn.';

  @override
  String get profile_retry => 'Thử lại';

  @override
  String get profile_error_title => 'Không thể tải nội dung';

  @override
  String get profile_edit_cover => 'Chỉnh sửa ảnh bìa';

  @override
  String get profile_add_to_story => 'Thêm vào tin';

  @override
  String get profile_edit_profile => 'Chỉnh sửa trang cá nhân';

  @override
  String get profile_tab_posts => 'Bài viết';

  @override
  String get profile_tab_photos => 'Ảnh';

  @override
  String get profile_tab_reels => 'Reels';

  @override
  String profile_friend_count(int count) {
    return '$count người bạn';
  }

  @override
  String get profile_friend_not_found => 'Không tìm thấy bạn bè';

  @override
  String get profile_section_about => 'Giới thiệu';

  @override
  String get profile_about_empty => 'Chưa có thông tin giới thiệu.';

  @override
  String get profile_section_photos => 'Ảnh';

  @override
  String get profile_photos_empty => 'Chưa có ảnh nào được chia sẻ.';

  @override
  String get profile_view_all => 'Xem tất cả';

  @override
  String get profile_section_friends => 'Bạn bè';

  @override
  String get profile_my_friends => 'Bạn bè của tôi';

  @override
  String get profile_friends_empty => 'Chưa có danh sách bạn bè.';

  @override
  String get profile_default_display_name => 'Người dùng';

  @override
  String get profile_user_title => 'Trang cá nhân';

  @override
  String get profile_add_friend => 'Kết bạn';

  @override
  String get profile_cancel_request => 'Hủy lời mời';

  @override
  String get profile_remove_friend => 'Hủy kết bạn';

  @override
  String get profile_friend_request_sent => 'Đã gửi lời mời kết bạn';

  @override
  String get profile_friend_request_cancelled => 'Đã hủy lời mời kết bạn';

  @override
  String get profile_friend_removed => 'Đã hủy kết bạn';

  @override
  String get profile_friend_request_failed => 'Không thể cập nhật trạng thái kết bạn.';

  @override
  String get profile_message => 'Nhắn tin';

  @override
  String get profile_message_unavailable => 'Chưa thể mở cuộc trò chuyện.';

  @override
  String get profile_like_error => 'Không thể cập nhật lượt thích.';

  @override
  String get profile_invalid_user_data => 'Không tìm thấy dữ liệu người dùng hợp lệ.';

  @override
  String get profile_avatar_take_photo => 'Chụp ảnh';

  @override
  String get profile_avatar_choose_gallery => 'Chọn từ thư viện';

  @override
  String get profile_avatar_updated => 'Đã cập nhật ảnh đại diện';

  @override
  String get profile_avatar_update_failed => 'Không thể cập nhật ảnh đại diện.';

  @override
  String get post_detail_title => 'Chi tiết bài viết';

  @override
  String get comment_input_hint => 'Viết bình luận...';

  @override
  String replying_to(Object name) {
    return 'Đang trả lời $name';
  }

  @override
  String get send => 'Gửi';

  @override
  String get comments_empty => 'Chưa có bình luận';

  @override
  String get comment_like => 'Thích';

  @override
  String get comment_reply => 'Trả lời';

  @override
  String get comment_load_failed => 'Không thể tải bình luận';

  @override
  String get comment_like_failed => 'Không thể thích bình luận';

  @override
  String get comment_action_failed => 'Không thể đăng bình luận';

  @override
  String get max_reply_depth => 'Chỉ hỗ trợ tối đa 3 tầng trả lời';

  @override
  String get delete_comment_confirm_title => 'Xóa';

  @override
  String get delete_post_confirm => 'Xóa bài viết này?';

  @override
  String get common_delete => 'Xóa';

  @override
  String get post_deleted => 'Đã xóa bài viết';

  @override
  String get post_delete_failed => 'Xóa bài viết thất bại';

  @override
  String get edit_post => 'Chỉnh sửa bài viết';

  @override
  String get edit_post_hint => 'Cập nhật nội dung';

  @override
  String get post_updated => 'Đã cập nhật bài viết';

  @override
  String get notification_title => 'Thông báo';

  @override
  String get notification_empty => 'Chưa có thông báo';

  @override
  String get notification_load_error => 'Không thể tải thông báo';

  @override
  String get notification_mark_all_read => 'Đánh dấu đã đọc';

  @override
  String get notification_just_now => 'Vừa xong';

  @override
  String get notification_minutes_ago => 'phút trước';

  @override
  String get notification_hours_ago => 'giờ trước';

  @override
  String get notification_days_ago => 'ngày trước';

  @override
  String get notification_friend_request => 'Lời mời kết bạn';

  @override
  String notification_friend_request_message(Object name) {
    return '$name đã gửi lời mời kết bạn cho bạn';
  }

  @override
  String get notification_friend_accepted => 'Đã chấp nhận kết bạn';

  @override
  String notification_friend_accepted_message(Object name) {
    return '$name đã chấp nhận lời mời kết bạn của bạn';
  }

  @override
  String get profile_pending_received => 'Chấp nhận';

  @override
  String get profile_reject_request => 'Từ chối';

  @override
  String get profile_friend_accepted => 'Đã chấp nhận lời mời kết bạn';

  @override
  String get profile_friend_rejected => 'Đã từ chối lời mời kết bạn';
}
