<?php

$config['v_records'] = array(
    'getRecords' => array(
        array(
            'field' => 'records_id',
            'label' => 'lang:records_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updRecords' => array(
        array(
            'field' => 'records_id',
            'label' => 'lang:records_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'records_id_origen',
            'label' => 'lang:records_id_origen',
            'rules' => 'integer|xss_clean'
        ),
        array(
            'field' => 'records_protected',
            'label' => 'lang:records_protected',
            'rules' => 'is_bool|xss_clean'
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
    'delRecords' => array(
        array(
            'field' => 'records_id',
            'label' => 'lang:records_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addRecords' => array(
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'categorias_codigo',
            'label' => 'lang:categorias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'records_id_origen',
            'label' => 'lang:records_id_origen',
            'rules' => 'integer|xss_clean'
        ),
        array(
            'field' => 'records_protected',
            'label' => 'lang:records_protected',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>