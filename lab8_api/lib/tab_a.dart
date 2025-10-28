import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'film.dart';

/// Tab A: Studio Ghibli Films search
/// Base URL: https://ghibliapi.vercel.app
///
/// UX:
/// - TextField for a title query (e.g., "Totoro")
/// - AppBar buttons: Fetch / Clear
/// - FutureBuilder shows Loading / Error / Empty / Data
class TabAPage extends StatefulWidget {
  const TabAPage({super.key});
  @override
  State<TabAPage> createState() => _TabAPageState();
}

class _TabAPageState extends State<TabAPage> {
  final _queryCtrl = TextEditingController();
  Future<List<Film>>? _future;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<List<Film>> _fetchFilms(String query) async {
  
    final uri = Uri.parse('https://ghibliapi.vercel.app/films'); 
    final res = await http.get(uri);                            // get the HTTP
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body);                          // parse the JSON
    if (data is! List) {
      return const <Film>[];
    }

    final films = data                                          // converts eash JSON object into a Film model
        .map((e) => Film.fromJson(e as Map<String, dynamic>))
        .toList();

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return films;                                

    // Client-side filter (case-insensitive) by title/original title
    return films.where((f) {
      final t1 = (f.title ?? '').toLowerCase();
      final t2 = (f.originalTitle ?? '').toLowerCase();
      return t1.contains(q) || t2.contains(q);
    }).toList();
  }

  /// Handles the Fetch action
  void _onFetch() {
    final q = _queryCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _future = _fetchFilms(q);       // assign the future 
    });
  }

  /// Handles the Clear action
  /// -clears the input and resets the Future
  void _onClear() {
    setState(() {
      _queryCtrl.clear();   // clear the TextField
      _future = null;       // remove current results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghibli Films'),  // Title on the top
        actions: [
          IconButton(onPressed: _onFetch, icon: const Icon(Icons.download)),  // Fetch button
          IconButton(onPressed: _onClear, icon: const Icon(Icons.clear_all)), // Clear button
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(                                  // TextField
              controller: _queryCtrl,
              decoration: const InputDecoration(
                labelText: 'Film title',
                hintText: 'e.g., Ponyo, Spirited Away',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onFetch(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _future == null
                  ? const _EmptyState(
                      message: 'Enter a film title and tap Fetch.',
                    )
                  : FutureBuilder<List<Film>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        final items = snap.data ?? const <Film>[];
                        if (items.isEmpty) {
                          return const _EmptyState(message: 'No results.');
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, i) {
                            final f = items[i];
                            return ListTile(
                              leading: const Icon(Icons.movie_outlined),
                              // Clear labels for each movie
                              title: Text(f.title ?? "(unknown)"),
                              subtitle: Text(
                                'Release: ${f.releaseDate ?? "—"}  |  Score: ${f.rtScore ?? "—"} ⭐\n'
                                'Director: ${f.director ?? "—"}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isThreeLine: true,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}



class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
