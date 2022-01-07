//                                                                            //
// Author(s):                                                                 //
//   Miguel Angel Sagreras                                                    //
//                                                                            //
// Copyright (C) 2015                                                         //
//    Miguel Angel Sagreras                                                   //
//                                                                            //
// This source file may be used and distributed without restriction provided  //
// that this copyright statement is not removed from the file and that any    //
// derivative work contains  the original copyright notice and the associated //
// disclaimer.                                                                //
//                                                                            //
// This source file is free software; you can redistribute it and/or modify   //
// it under the terms of the GNU General Public License as published by the   //
// Free Software Foundation, either version 3 of the License, or (at your     //
// option) any later version.                                                 //
//                                                                            //
// This source is distributed in the hope that it will be useful, but WITHOUT //
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      //
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   //
// more details at http://www.gnu.org/licenses/.                              //
//                                                                            //

const i18n = {

	'background'   : { en : 'Background',    es : 'Color de Fondo'        },
	'freeze'       : { en : 'Freeze',        es : 'Congelar'              },
	'gridbg'       : { en : 'Grid BG',       es : 'Fondo de la Grilla'    },
	'gridfg'       : { en : 'Grid FG',       es : 'Frente de la Grilla'   },
	'horizontalbg' : { en : 'Horizontal BG', es : 'Fondo del horizontal'  },
	'horizontalfg' : { en : 'Horizontal FG', es : 'Frente del horizontal' },
	'negative'     : { en : 'Negative',      es : 'Negativa'              },
	'positive'     : { en : 'Positive',      es : 'Positiva'              },
	'segmentbg'    : { en : 'Segment BG',    es : 'Fondo del segmento'    },
	'textbg'       : { en : 'Text BG',       es : 'Fondo del texto'       },
	'textfg'       : { en : 'Text FG',       es : 'Frente del texto'      },
	'verticalbg'   : { en : 'Vertical BG',   es : 'Fondo del vertical'    },
	'verticalfg'   : { en : 'Vertical FG',   es : 'Frente del vertical'   },


	'inputs'      : { en : 'Inputs ',     es : 'Entradas'     },

	'horizontal'  : { en : 'Horizontal',  es : 'Horizontal'   },
	'mode'        : { en : 'Mode',        es : 'Modo'         },
	'normal'      : { en : 'Normal',      es : 'Normal'       },
	'normal+free' : { en : 'Normal+Free', es : 'Normal+Libre' },
	'level'       : { en : 'Level',       es : 'Nivel'        },
	'offset'      : { en : 'Offset',      es : 'Posicion'     },
	'one shot'    : { en : 'One shot',    es : 'Un disparo'   },
	'scale'       : { en : 'Scale',       es : 'Escala'       },
	'slope'       : { en : 'Slope',       es : 'Pendiente'    },
	'trigger'     : { en : 'Trigger',     es : 'Disparo'      },
	'vertical'    : { en : 'Vertical',    es : 'Vertical'     },
	'vtaxis'      : { en : 'Scale',       es : 'Escala'       } };

var lang = 'en';

function setLang(l) {
	lang = l;
}

function getLang(l) {
	return lang;
}
