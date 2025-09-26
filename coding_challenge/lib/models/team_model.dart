class Team {
  final int id;
  final String name;
  final String logo;
  final String country;
  final String founded;
  final String venue;
  final String venueCity;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    required this.country,
    required this.founded,
    required this.venue,
    required this.venueCity,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Team',
      logo: json['logo'] ?? '',
      country: json['country'] ?? 'Unknown Country',
      founded: json['founded']?.toString() ?? 'Unknown',
      venue: json['venue']?['name'] ?? 'Unknown Venue',
      venueCity: json['venue']?['city'] ?? 'Unknown City',
    );
  }

  // Mock data for testing without API
  static List<Team> getMockTeams() {
    return [
      Team(
        id: 1,
        name: 'Manchester United',
        logo: 'https://media.api-sports.io/football/teams/33.png',
        country: 'England',
        founded: '1878',
        venue: 'Old Trafford',
        venueCity: 'Manchester',
      ),
      Team(
        id: 2,
        name: 'Real Madrid',
        logo: 'https://media.api-sports.io/football/teams/541.png',
        country: 'Spain',
        founded: '1902',
        venue: 'Santiago Bernabéu',
        venueCity: 'Madrid',
      ),
      Team(
        id: 3,
        name: 'Barcelona',
        logo: 'https://media.api-sports.io/football/teams/529.png',
        country: 'Spain',
        founded: '1899',
        venue: 'Camp Nou',
        venueCity: 'Barcelona',
      ),
      Team(
        id: 4,
        name: 'Bayern Munich',
        logo: 'https://media.api-sports.io/football/teams/157.png',
        country: 'Germany',
        founded: '1900',
        venue: 'Allianz Arena',
        venueCity: 'Munich',
      ),
      Team(
        id: 5,
        name: 'Liverpool',
        logo: 'https://media.api-sports.io/football/teams/40.png',
        country: 'England',
        founded: '1892',
        venue: 'Anfield',
        venueCity: 'Liverpool',
      ),
      Team(
        id: 6,
        name: 'Paris Saint-Germain',
        logo: 'https://media.api-sports.io/football/teams/85.png',
        country: 'France',
        founded: '1970',
        venue: 'Parc des Princes',
        venueCity: 'Paris',
      ),
      Team(
        id: 7,
        name: 'Juventus',
        logo: 'https://media.api-sports.io/football/teams/496.png',
        country: 'Italy',
        founded: '1897',
        venue: 'Allianz Stadium',
        venueCity: 'Turin',
      ),
      Team(
        id: 8,
        name: 'Chelsea',
        logo: 'https://media.api-sports.io/football/teams/49.png',
        country: 'England',
        founded: '1905',
        venue: 'Stamford Bridge',
        venueCity: 'London',
      ),
      Team(
        id: 9,
        name: 'Arsenal',
        logo: 'https://media.api-sports.io/football/teams/42.png',
        country: 'England',
        founded: '1886',
        venue: 'Emirates Stadium',
        venueCity: 'London',
      ),
      Team(
        id: 10,
        name: 'AC Milan',
        logo: 'https://media.api-sports.io/football/teams/489.png',
        country: 'Italy',
        founded: '1899',
        venue: 'San Siro',
        venueCity: 'Milan',
      ),
    ];
  }
}
