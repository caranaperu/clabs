<?php

$config['v_productodetalle'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_id_origen',
            'label' => 'lang:insumo_id_origen',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'producto_detalle_cantidad',
            'label' => 'lang:producto_detalle_cantidad',
            'rules' => 'required|decimal|greater_than[0.00] | xss_clean'
        ),
        array(
            'field' => 'producto_detalle_valor',
            'label' => 'lang:producto_detalle_valor',
            'rules' => 'required|decimal|greater_than_equal[0.00] | xss_clean'
        ),
        array(
            'field' => 'producto_detalle_merma',
            'label' => 'lang:producto_detalle_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00] | xss_clean'
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
    'delProductoDetalle' => array(
        array(
            'field' => 'producto_detalle_id',
            'label' => 'lang:producto_detalle_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addProductoDetalle' => array(
        array(
            'field' => 'insumo_id_origen',
            'label' => 'lang:insumo_id_origen',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'insumo_id',
            'label' => 'lang:insumo_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'unidad_medida_codigo',
            'label' => 'lang:unidad_medida_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[8]'
        ),
        array(
            'field' => 'producto_detalle_cantidad',
            'label' => 'lang:producto_detalle_cantidad',
            'rules' => 'required|decimal|greater_than[0.00] | xss_clean'
        ),
        array(
            'field' => 'producto_detalle_valor',
            'label' => 'lang:producto_detalle_valor',
            'rules' => 'required|decimal|greater_than_equal[0.00] | xss_clean'
        ),
        array(
            'field' => 'producto_detalle_merma',
            'label' => 'lang:producto_detalle_merma',
            'rules' => 'required|decimal|greater_than_equal[0.00] | xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>