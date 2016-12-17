<?php

$config['v_cotizacion_detalle'] = [
    'getCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ]
    ],
    'updCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'cotizacion_detalle_cantidad',
            'label' => 'lang:cotizacion_detalle_cantidad',
            'rules' => 'required|decimal|greater_than_equal[0.01] |xss_clean'
        ],
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[8]'
        ],
        [
            'field' => 'cotizacion_detalle_precio',
            'label' => 'lang:cotizacion_detalle_precio',
            'rules' => 'required|decimal|greater_than_equal[0.00] |xss_clean'
        ],
        [
            'field' => 'cotizacion_detalle_total',
            'label' => 'lang:cotizacion_detalle_total',
            'rules' => 'required|decimal|greater_than_equal[0.00] |xss_clean'
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        ]
    ],
    'delCotizacionDetalle' => [
        [
            'field' => 'cotizacion_detalle_id',
            'label' => 'lang:cotizacion_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        ]
    ],
    'addCotizacionDetalle' => [
        [
            'field' => 'cotizacion_id',
            'label' => 'lang:cotizacion_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ],
        [
            'field' => 'cotizacion_detalle_cantidad',
            'label' => 'lang:cotizacion_detalle_cantidad',
            'rules' => 'required|decimal|greater_than_equal[0.01] |xss_clean'
        ],
        [
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[8]'
        ],
        [
            'field' => 'cotizacion_detalle_precio',
            'label' => 'lang:cotizacion_detalle_precio',
            'rules' => 'required|decimal|greater_than_equal[0.00] |xss_clean'
        ],
        [
            'field' => 'cotizacion_detalle_total',
            'label' => 'lang:cotizacion_detalle_total',
            'rules' => 'required|decimal|greater_than_equal[0.00] |xss_clean'
        ],
        [
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        ]
    ]
];
?>