node_descriptions = {
    ['gunner'] = 'shoots 6 bullets p/second, medium range',
    ['ranger'] = 'shoots 4 bullets p/second, global range',
    ['overclock'] = 'shoots 9 bullets p/second, very short range',
    ['ammo'] = 'uploads 6 bullets p/second to connected nodes',
    ['shield'] = 'creates a large protective field around self, uses bullets',
    ['generator'] = 'uploads 0.9 u/s to the core',
    ['processing_unit'] = 'will combine two ammunitions',
    ['flame_gen'] = 'add flame effect to bullets - enemies take dmg overtime and spread to nearby enemies',
    ['shock_gen'] = 'add shock effect to bullets - enemies take dmg over time',
    ['rocket_gen'] = 'add seeking and ichor effect to bullets, enemies affected take 20% more dmg',
    ['explosive_gen'] = 'add explosive effect to bullets - do AoE dmg',
}


node_to_color = {
    ['gunner'] = colors.orange,
    ['ranger'] = colors.ranger,
    ['overclock'] = colors.purple,
    ['ammo'] = colors.green,
    ['shield'] = colors.blue,
    ['generator'] = colors.white,
    ['core'] = colors.yellow,
    ['processing_unit'] = colors.purple,
    ['flame_gen'] = colors.red,
    ['shock_gen'] = colors.blue2,
    ['rocket_gen'] = colors.yellow,
    ['explosive_gen'] = colors.white2,
}
