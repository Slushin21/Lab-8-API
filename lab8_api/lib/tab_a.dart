import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'film.dart';

/// Author: Eric Puksich
/// Date: 10/28/25
/// Bugs: None that I know of
/// Description: Tab for Lab 8 that uses the Ghibli API, has text field to search a title 
///               of a Ghibli movie and the tab outputs a list of movies with that word in the title
///               including the movie director, rating, and release date.
/// Reflection: This lab was fun to use an API to get data, I wish I could have used more of the API's so I might play around with that outside of class
/// LLM Usage: Just asked it for help with the emulator as it wasn't working for a little bit. 
///            Also helped me make sure I pushed to github correctly because I wanted to make sure I didn't delete everything by accident
class TabAPage extends StatefulWidget {
  const TabAPage({super.key});
  @override
  State<TabAPage> createState() => _TabAPageState();
}

class _TabAPageState extends State<TabAPage> {
  final _queryControl = TextEditingController();
  Future<List<Film>>? _future;

  @override
  void dispose() {
    _queryControl.dispose();
    super.dispose();
  }

  Future<List<Film>> _fetchFilms(String query) async {
  
    final uri = Uri.parse('https://ghibliapi.vercel.app/films'); 
    final res = await http.get(uri);                            // get the HTTP
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');                // if error occurs trying to reach API, show error message
    }

    final data = jsonDecode(res.body);                          // parse the JSON
    if (data is! List) {
      return const <Film>[];
    }

    final films = data                                          // converts each JSON object into a Film model
        .map((e) => Film.fromJson(e as Map<String, dynamic>))
        .toList();

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return films;                                

    return films.where((f) {                              // filter the full list
      final t1 = (f.title ?? '').toLowerCase();           // english title to lowercase  
      final t2 = (f.originalTitle ?? '').toLowerCase();   // original japanese title to lowercase
      return t1.contains(q) || t2.contains(q);            // if match is found add to list
    }).toList();
  }

  /// Handles the Fetch action
  void _onFetch() {
    final q = _queryControl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _future = _fetchFilms(q);       // assign the future 
    });
  }

  /// Handles the Clear action
  /// -clears the input and resets the Future
  void _onClear() {
    setState(() {
      _queryControl.clear();   // clear the TextField
      _future = null;         // remove current results
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghibli Films'),  // Title on the top
        actions: [
          IconButton(onPressed: _onFetch, icon: const Icon(Icons.download)),  // Fetch button
          IconButton(onPressed: _onClear, icon: const Icon(Icons.clear)), // Clear button
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(                                  // TextField
              controller: _queryControl,
              decoration: const InputDecoration(
                labelText: 'Film title',                  // descriptors for what to search for
                hintText: 'e.g., Ponyo, Spirited Away',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onFetch(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _future == null
                  ? const _EmptyState(                              // if future is null then prompt to search for a film
                      message: 'Enter a film title and tap Fetch.',
                    )
                  : FutureBuilder<List<Film>>(                      // if there is a future load data
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {  // while fetching data show a loading
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {                                    // if an error happens, show an error message
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        final items = snap.data ?? const <Film>[];
                        if (items.isEmpty) {                                    // if after fetch there are no results, show message
                          return const _EmptyState(message: 'No results.');
                        }
                        return ListView.separated(                                // listview of films
                          itemCount: items.length,                                // number of films found
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, i) {
                            final f = items[i];
                            return ListTile(                                      // each film
                              leading: const Icon(Icons.movie_outlined),
                              title: Text(f.title ?? "(unknown)"),                // Clear labels for each film
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


/// Helper state of the widget before searching for a film
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
