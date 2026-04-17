import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'seat_page.dart';

class ShowingPage extends StatelessWidget {
  final String movieTitle;
  final bool isMember; 

  const ShowingPage({
    super.key,
    required this.movieTitle,
    required this.isMember, 
  });

  @override
  Widget build(BuildContext context) {
    final movie = movies.firstWhere((m) => m.title == movieTitle);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Stack(
        children: [

          // ===== 主体滚动内容 =====
          CustomScrollView(
            slivers: [

              // ===== Hero + 标题叠加 =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Hero(
                      tag: "${movie.id}_${DateTime.now().millisecondsSinceEpoch}",
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),

                        child: Stack(
                          children: [

                            // 海报
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: Image.asset(
                                  movie.poster,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // 渐变遮罩
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black
                                          .withOpacity(0.85),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 标题 + 评分
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style:
                                        const TextStyle(
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color:
                                            Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                          width: 6),
                                      Text(
                                        movie.rating
                                            .toString(),
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ===== 详情信息区 =====
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                        24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                            maxWidth: 720),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                                '${movie.duration} min'),
                            ...movie.genres
                                .map((g) =>
                                    _InfoChip(g)),
                          ],
                        ),
                        const SizedBox(
                            height: 20),
                        Text(
                          movie.description,
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(
                            height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== 场次列表 =====
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                        24, 16, 24, 24),
                sliver: SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final showing =
                          showings[index];
                      return Card(
                        margin:
                            const EdgeInsets.only(
                                bottom: 12),
                        child: ListTile(
                          title: Text(
                              '${showing.time} - ${showing.hallType}'),
                          trailing:
                              const Icon(Icons.event_seat),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeatPage(
                                    hallType: showing.hallType, // ⭐ 从数据拿
                                    isMember: isMember,         // ⭐ 直接用变量
                                  ),
                                ),
                              );
                          },
                        ),
                      );
                    },
                    childCount:
                        showings.length,
                  ),
                ),
              ),
            ],
          ),

          // ===== 🔙 悬浮返回按钮 =====
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ===== 小标签 =====
class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.white.withOpacity(0.12),
    );
  }
}
