<?php

$config['v_unidadmedida_conversion'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'unidad_medida_origen',
            'label' => 'lang:unidad_medida_origen',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_destino',
            'label' => 'lang:unidad_medida_destino',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_conversion_factor',
            'label' => 'lang:unidad_medida_conversion_factor',
            'rules' => 'required|decimal|greater_than[0.00] | xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_conversion_id',
            'label' => 'lang:unidad_medida_conversion_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addUnidadMedidaConversion' => array(
        array(
            'field' => 'unidad_medida_origen',
            'label' => 'lang:unidad_medida_origen',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_destino',
            'label' => 'lang:unidad_medida_destino',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'unidad_medida_conversion_factor',
            'label' => 'lang:unidad_medida_conversion_factor',
            'rules' => 'required|decimal|greater_than[0.00] | xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>