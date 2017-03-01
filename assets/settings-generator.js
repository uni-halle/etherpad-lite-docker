/**
 * This program is free software and available under the MIT license.
 */

( function () {
	'use strict';
	var penv = process.env;
	var settings = {
		title: penv.ETHERPAD_TITLE,
		ip: '0.0.0.0',
		port: penv.ETHERPAD_PORT,
		dbType: 'mysql',
		dbSettings: {
			user: penv.ETHERPAD_DB_USER,
			host: penv.ETHERPAD_DB_HOST,
			port: penv.ETHERPAD_DB_PORT,
			password: penv.ETHERPAD_DB_PASSWORD,
			database: penv.ETHERPAD_DB_NAME
		}
	};
	if ( penv.ETHERPAD_DEFAULT_PAD_TEXT ) {
		settings['defaultPadText'] = penv.ETHERPAD_DEFAULT_PAD_TEXT;
	}
	if ( penv.ETHERPAD_ADMIN_PASSWORD ) {
		settings['users'] = {};
		settings['users'][penv.ETHERPAD_ADMIN_USER] = {
			password: penv.ETHERPAD_ADMIN_PASSWORD,
			is_admin: true
		};
	}
	if ( penv.ETHERPAD_SESSION_REQUIRED ) {
		settings['requireSession'] = true;
	}
	process.stdout.write( JSON.stringify( settings, null, 4 ) );
} () );

