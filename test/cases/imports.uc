import * as fs from 'fs';
import { connect } from 'socket';
import { cursor as uci_cursor } from 'uci';
import { helper } from './local/helper.uc';

let log = require('log');
let ubus = require("ubus");

export const VERSION = 1;

export function version() {
	return VERSION;
};
