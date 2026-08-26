class EmergencyContact {
  final String state;
  final String name;
  final List<String> phoneNumbers;
  final String locationSearchQuery;

  const EmergencyContact({
    required this.state,
    required this.name,
    required this.phoneNumbers,
    required this.locationSearchQuery,
  });

  static List<EmergencyContact> get allContacts => [
    const EmergencyContact(
      state: 'PERLIS',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI PERLIS',
      phoneNumbers: ['04-9777991', '04-9778991'],
      locationSearchQuery: 'Perlis Civil Defense State Office',
    ),
    const EmergencyContact(
      state: 'KEDAH',
      name: 'PEJABAT PERTAHANAN AWAM DAERAH KOTA SETAR',
      phoneNumbers: ['04-7323810', '04-7323801'],
      locationSearchQuery: 'Pejabat Daerah Pertahanan Awam Kota Setar',
    ),
    const EmergencyContact(
      state: 'PULAU PINANG',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI PULAU PINANG',
      phoneNumbers: ['04-2263876'],
      locationSearchQuery: 'Pejabat Negeri Pertahanan Awam Pulau Pinang',
    ),
    const EmergencyContact(
      state: 'PERAK',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI PERAK',
      phoneNumbers: ['05-5278715'],
      locationSearchQuery: 'State Secretary of the Corporation SSI',
    ),
    const EmergencyContact(
      state: 'SELANGOR',
      name: 'PEJABAT PERTAHANAN AWAM DAERAH KLANG',
      phoneNumbers: ['03-33710820'],
      locationSearchQuery: 'Klang Civil Defence District Office',
    ),
    const EmergencyContact(
      state: 'WP KUALA LUMPUR',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI WP KUALA LUMPUR',
      phoneNumbers: ['03-26871400'],
      locationSearchQuery: 'Pejabat Negeri Pertahanan Awam Wilayah Persekutuan',
    ),
    const EmergencyContact(
      state: 'PAHANG',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI PAHANG',
      phoneNumbers: ['09-5445991'],
      locationSearchQuery: 'Pahang Civil Defense State Office',
    ),
    const EmergencyContact(
      state: 'TERENGGANU',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI TERENGGANU',
      phoneNumbers: ['09-6668246', '09-6672991'],
      locationSearchQuery: 'Terengganu Civil Defense State Office',
    ),
    const EmergencyContact(
      state: 'KELANTAN',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI KELANTAN',
      phoneNumbers: ['09-7474091'],
      locationSearchQuery: 'APM Negeri Kelantan',
    ),
    const EmergencyContact(
      state: 'NEGERI SEMBILAN',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI NEGERI SEMBILAN',
      phoneNumbers: ['06-7645755'],
      locationSearchQuery: 'Malaysia Civil Defence Force Negeri Sembilan',
    ),
    const EmergencyContact(
      state: 'MELAKA',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI MELAKA',
      phoneNumbers: ['06-2324028'],
      locationSearchQuery: 'Angkatan Pertahanan Awam Malaysia Negeri Melaka',
    ),
    const EmergencyContact(
      state: 'JOHOR',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI JOHOR',
      phoneNumbers: ['07-2349706', '07-2349708', '07-2349709'],
      locationSearchQuery: 'Angkatan Pertahanan Awam Negeri Johor',
    ),
    const EmergencyContact(
      state: 'SABAH',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI SABAH',
      phoneNumbers: ['088-232440', '088-232453'],
      locationSearchQuery: 'Pejabat Negeri Pertahanan Awam Sabah',
    ),
    const EmergencyContact(
      state: 'SARAWAK',
      name: 'PEJABAT PERTAHANAN AWAM NEGERI SARAWAK',
      phoneNumbers: ['082-433896', '082-370205'],
      locationSearchQuery: 'Jalan Kampung Simpang Tiga, Kampung Kenyalang Park, 93300 Kuching, Sarawak',
    ),
  ];
}
