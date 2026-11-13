import 'package:flutter/material.dart';
import '../api_client.dart';
import 'login.dart';
import 'post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // 投稿一覧
  List<PostData> posts = [];

  // ★ここから追加: サーバーから取得した投稿
  List<Map<String, dynamic>> serverPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiClient.fetchPosts();
      if (!mounted) return;
      setState(() {
        serverPosts = result;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '投稿の読み込みに失敗しました';
        _loading = false;
      });
    }
  }
  // ★ここまで追加

Future<void> openPostPage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PostPage(userName: 'saru',),
    ),
  );
  // 戻ってきたら最新を読み直す
  _loadPosts();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('さんさるトーク'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            '投稿一覧',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),


          // ★サーバーから取得した投稿
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Column(
              children: [
                Text(_error!),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadPosts,
                  child: const Text('再読み込み'),
                ),
              ],
            )
          else if (serverPosts.isEmpty)
            const Center(child: Text('まだ投稿がありません'))
          else
            ...serverPosts.map((post) {
              final user = post['user'] as Map<String, dynamic>? ?? {};
              final name = user['displayName'] ?? user['username'] ?? '不明';
              final content = post['content'] ?? post['text'] ?? '';
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name.toString()),
                  subtitle: Text(content.toString()),
                ),
              );
            }),
        ],
      ),

      // 下部メニュー
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,

        onTap: (index) {
          if (index == 2) {
            openPostPage();
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '投稿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

