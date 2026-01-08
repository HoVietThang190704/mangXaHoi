import 'package:flutter/material.dart';

class StoryBarComponent extends StatelessWidget{
  final List<Map<String,String>> stories;
  StoryBarComponent({Key? key, this.stories = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(stories.isEmpty){
      return SizedBox(height: 12); // no stories, render small spacer
    }

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index){
          final s = stories[index];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Center(child: Text(s['name'] != null && s['name']!.isNotEmpty ? s['name']![0] : '?', style: TextStyle(fontWeight: FontWeight.bold))),
              ),
              SizedBox(height:4),
              Text(s['name'] ?? '', style: TextStyle(fontSize:12, overflow: TextOverflow.ellipsis)),
            ],
          );
        },
        separatorBuilder: (_, __) => SizedBox(width:12),
        itemCount: stories.length,
      ),
    );
  }
}
