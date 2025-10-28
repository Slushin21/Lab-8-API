import 'package:flutter/material.dart';
import 'dart:convert'; // for jsonDecode()
import 'package:http/http.dart' as http; // for making HTTP requests

/// Name: Joey Lantz
/// Date: 10-28-2025
/// Description: A Flutter widget that fetches and displays brewery data from the Open Brewery DB API based on user-input city names.
/// Bugs: None known
/// Reflections: This was a great exercise in working with asynchronous data fetching and managing state in Flutter.  I learned a lot
/// about API integration and FutureBuilders.  I did have some trouble getting the brewery data to display correctly at first, but after reviewing the API documentation
/// and debugging my code, I was able to resolve the issues.  Overall, I found this lab to be very educational and enjoyable.
class BreweryTab extends StatefulWidget {
  const BreweryTab({super.key});

  @override
  State<BreweryTab> createState() => _BreweryTabState();
}

class _BreweryTabState extends State<BreweryTab> {
  // Controller for the TextField where user types the city name.
  final TextEditingController _cityController = TextEditingController();

  // A Future that will hold the brewery data after fetching.
  Future<List<dynamic>>? _breweryFuture;

  /// Fetches brewery data from the API based on the entered city.
  Future<List<dynamic>> fetchBreweries(String city) async {
    final url =
        Uri.parse('https://api.openbrewerydb.org/v1/breweries?by_city=$city'); // Construct the API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the JSON body (which is a list of brewery objects)
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load breweries'); // Handle error response
    }
  }

  // Clears the current Future and text input.
  void clearData() {
    setState(() {
      _breweryFuture = null;
      _cityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brewery Finder'),
        actions: [
          // "Fetch" button: triggers API call
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Fetch Data',
            onPressed: () {
              final city = _cityController.text.trim(); // Get the entered city name
              if (city.isNotEmpty) {
                setState(() {
                  _breweryFuture = fetchBreweries(city); // Start fetching data
                });
              }
            },
          ),
          // "Clear" button: resets the data
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Data',
            onPressed: clearData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Input field for city name
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter a city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // FutureBuilder shows data depending on connection state
            Expanded(
              child: _breweryFuture == null // No data fetched yet
                  ? const Center(
                      child: Text(
                        'Enter a city and tap the download icon to fetch breweries.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: _breweryFuture,
                      builder: (context, snapshot) {
                        // Show different states of the Future
                        if (snapshot.connectionState == ConnectionState.waiting) { 
                          return const Center(child: CircularProgressIndicator()); // Loading state
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}', // Display error message
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) { // No data found
                          return const Center(
                              child: Text('No breweries found for this city.'));
                        }

                        // If data was fetched successfully, display in a ListView
                        final breweries = snapshot.data!;
                        return ListView.builder(
                          itemCount: breweries.length,
                          itemBuilder: (context, index) {
                            final brewery = breweries[index]; 
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: ListTile(
                                title: Text(
                                  brewery['name'] ?? 'Unknown Brewery', // Brewery name
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Type: ${brewery['brewery_type'] ?? 'N/A'}\n'
                                  'City: ${brewery['city'] ?? 'Unknown'}', // Brewery type and city
                                ),
                                trailing: const Icon(Icons.local_drink),
                                onTap: () {
                                  final website = brewery['website_url']; // Brewery website
                                  if (website != null && website.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Website: $website'),
                                        duration: const Duration(seconds: 2), // Show website URL for two seconds
                                      ),
                                    );
                                  }
                                },
                              ),
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
