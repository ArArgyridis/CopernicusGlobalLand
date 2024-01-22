/*
Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import { readonly, writable } from 'svelte/store';
import { Boundary } from "../lib/base/CGLSDataConstructors.js";

//boundaries info
let tmpBoundaries = { 10000000: new Boundary({ id: 10000000, description: "No Boundary", url: null }) }
export const boundaries = writable(tmpBoundaries);
export const currentBoundary = writable(tmpBoundaries[10000000]);
