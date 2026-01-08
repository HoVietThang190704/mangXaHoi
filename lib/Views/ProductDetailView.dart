import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../Components/AppBarComponent.dart';
import '../Components/BottomNavigationBarComponent.dart';

class ProductDetailView extends StatelessWidget{
  late int Id;
  ProductDetailView(int Id){
    this.Id = Id;
  }
  //html from api
  String data = r"""<h1 class="title-detail">Đại biểu Quốc hội: Cần r&otilde; lộ tr&igrave;nh bỏ cơ chế ph&acirc;n bổ 'room' t&iacute;n dụng</h1>
  <p class="description">Đại biểu Nguyễn Thị Việt Nga đề nghị Ng&acirc;n h&agrave;ng Nh&agrave; nước x&acirc;y dựng lộ tr&igrave;nh cụ thể, tiến tới bỏ hạn mức tăng trưởng t&iacute;n dụng.</p>
  <article class="fck_detail ">
  <p class="Normal">Đề nghị tr&ecirc;n được Ph&oacute; đo&agrave;n đại biểu TP Hải Ph&ograve;ng Nguyễn Thị Việt Nga n&ecirc;u tại phi&ecirc;n thảo luận ở hội trường, s&aacute;ng 3/12.</p>
  <p class="Normal">Theo b&aacute;o c&aacute;o của Ch&iacute;nh phủ, năm nay Ng&acirc;n h&agrave;ng Nh&agrave; nước đ&atilde; điều chỉnh ti&ecirc;u ch&iacute; giao hạn mức tăng trưởng t&iacute;n dụng, ph&acirc;n loại ng&acirc;n h&agrave;ng theo mức độ an to&agrave;n. Một số nh&agrave; băng được chủ động hơn trong kiểm so&aacute;t room t&iacute;n dụng.</p>
  <p class="Normal">Tuy nhi&ecirc;n, b&agrave; Nga nh&igrave;n nhận thực tế cơ chế ph&acirc;n bổ "quota" t&iacute;n dụng vẫn được duy tr&igrave;, th&ocirc;ng qua việc Ng&acirc;n h&agrave;ng Nh&agrave; nước giao v&agrave; điều chỉnh chỉ ti&ecirc;u cụ thể cho từng nh&agrave; băng.</p>
  <p class="Normal">"Hiện chưa r&otilde; lộ tr&igrave;nh x&oacute;a bỏ cơ chế n&agrave;y thế n&agrave;o. Nh&agrave; điều h&agrave;nh chưa l&yacute; giải v&igrave; sao sau nhiều năm được y&ecirc;u cầu bỏ quota m&agrave; vẫn chưa c&oacute; mốc thời gian, giải ph&aacute;p cụ thể", b&agrave; n&oacute;i, đồng thời đề nghị cơ quan quản l&yacute; cần x&acirc;y dựng v&agrave; b&aacute;o c&aacute;o Quốc hội lộ tr&igrave;nh bỏ hẳn cơ chế ph&acirc;n bổ "room" t&iacute;n dụng mang t&iacute;nh h&agrave;nh ch&iacute;nh.</p>
  <p class="Normal">Trong thời gian chưa bỏ được ho&agrave;n to&agrave;n, b&agrave; Nga cho rằng việc ph&acirc;n bổ "room" cần được thực hiện ổn định, hạn chế điều chỉnh v&agrave;o giữa năm. "Nh&agrave; điều h&agrave;nh cần mở rộng số lượng tổ chức t&iacute;n dụng được tự chủ kiểm so&aacute;t tăng trưởng t&iacute;n dụng trong khung an to&agrave;n đ&atilde; định", b&agrave; kiến nghị.</p>
  <figure class="tplCaption action_thumb_added" data-size="true">
  <div class="fig-picture el_valid" data-width="680" data-src="https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=0&amp;h=0&amp;q=100&amp;dpr=2&amp;fit=crop&amp;s=8W3-OktMbCbn0DGdVcxd0w" data-sub-html="&lt;div class=&quot;ss-wrapper&quot;&gt;&lt;div class=&quot;ss-content&quot;&gt;
  &lt;p class=&quot;Image&quot;&gt;Ph&oacute; đo&agrave;n đại biểu TP Hải Ph&ograve;ng Nguyễn Thị Việt Nga ph&aacute;t biểu s&aacute;ng 3/12. Ảnh: &lt;em&gt;Media Quốc hội&lt;/em&gt;&lt;/p&gt;
  &lt;/div&gt;&lt;/div&gt;"><picture><source srcset="https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=lagycyr7yXjbZzMWP9J7nA 1x, https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=1020&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=tbe1fRd6NcebtpnkzO4Vng 1.5x, https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=2&amp;fit=crop&amp;s=G0TIjoxJTRpm2uGmZbMXtw 2x" data-srcset="https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=lagycyr7yXjbZzMWP9J7nA 1x, https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=1020&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=tbe1fRd6NcebtpnkzO4Vng 1.5x, https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=2&amp;fit=crop&amp;s=G0TIjoxJTRpm2uGmZbMXtw 2x" /><img class="lazy lazied" src="https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=lagycyr7yXjbZzMWP9J7nA" alt="Ph&oacute; đo&agrave;n đại biểu TP Hải Ph&ograve;ng Nguyễn Thị Việt Nga ph&aacute;t biểu s&aacute;ng 3/12. Ảnh: Media Quốc hội" data-src="https://i1-kinhdoanh.vnecdn.net/2025/12/03/viet-nga-1764735867-2227-1764736571.jpg?w=680&amp;h=0&amp;q=100&amp;dpr=1&amp;fit=crop&amp;s=lagycyr7yXjbZzMWP9J7nA" data-ll-status="loaded" /></picture></div>
  <figcaption>
  <p class="Image">Ph&oacute; đo&agrave;n đại biểu TP Hải Ph&ograve;ng Nguyễn Thị Việt Nga ph&aacute;t biểu s&aacute;ng 3/12. Ảnh:&nbsp;<em>Media Quốc hội</em></p>
  </figcaption>
  </figure>
  <p class="Normal">Cơ chế hạn mức t&iacute;n dụng đ&atilde; được Ng&acirc;n h&agrave;ng Nh&agrave; nước duy tr&igrave; suốt chục năm qua. Đ&acirc;y l&agrave; c&ocirc;ng cụ để cơ quan n&agrave;y kiểm so&aacute;t chất lượng cho vay cũng như phục vụ c&aacute;c mục ti&ecirc;u kinh tế vĩ m&ocirc; kh&aacute;c như l&atilde;i suất, cung tiền v&agrave; lạm ph&aacute;t. Nhưng hiện c&ocirc;ng cụ n&agrave;y bị cho l&agrave; tạo cơ chế xin - cho, một số trường hợp khiến người vay kh&ocirc;ng thể tiếp cận t&iacute;n dụng nếu nh&agrave; băng kh&ocirc;ng c&ograve;n hạn mức.</p>
  </article>""";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBarComponent("Home"),
      body: SingleChildScrollView(
          child:Column(children: [
            Text("Product Id: ${Id}"),
            Html(
              data: data,
            )

          ],)
      )
      ,
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }

}