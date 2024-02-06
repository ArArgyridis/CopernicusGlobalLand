/*
   Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com
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
import { Product } from "../lib/base/CGLSDataConstructors.js";

//initializing objects with dummy values
let tmpNullId = 10000000;
export let nullId = readonly(writable(tmpNullId));

//category info
export const categories = writable([]);
export const currentCategory = writable(null);

//product info
export const products = writable({});
export const currentProduct = writable(null);

//date info
let tmpDate = new Date();
tmpDate.setFullYear(tmpDate.getFullYear() - 2);
export const dateStart = writable(tmpDate);
export const dateEnd = writable(new Date());

//map style cache
export const styleCache = writable({});

//product downloader panel
export const showProductDownloadPanel = writable(false);