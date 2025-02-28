// Copyright (c) <2015> <Miguel Angel Sagreras>                                    //
//                                                                                 //
// Permission is hereby granted, free of charge, to any person obtaining a copy of //
// this software and associated documentation files (the "Software"), to deal in   //
// the Software without restriction, including without limitation the rights to    //
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   //
// of the Software, and to permit persons to whom the Software is furnished to do  //
// so, subject to the following conditions:                                        //
//                                                                                 //
// The above copyright notice and this permission notice shall be included in all  //
// copies or substantial portions of the Software.                                 //
//                                                                                 //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   //
// SOFTWARE.                                                                       //
//                                                                                 //

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

