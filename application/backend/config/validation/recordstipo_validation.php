<?php

$config['v_records_tipo'] = array(
    'getRecordsTipo' => array(
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        )
    ),
    'updRecordsTipo' => array(
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'records_tipo_descripcion',
            'label' => 'lang:records_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'records_tipo_abreviatura',
            'label' => 'lang:records_tipo_abreviatura',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[2]'
        ),
        array(
            'field' => 'records_tipo_tipo',
            'label' => 'lang:records_tipo_tipo',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'records_tipo_clasificacion',
            'label' => 'lang:records_tipo_clasificacion',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'records_tipo_peso',
            'label' => 'lang:records_tipo_peso',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'records_tipo_protected',
            'label' => 'lang:records_tipo_protected',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delRecordsTipo' => array(
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addRecordsTipo' => array(
        array(
            'field' => 'records_tipo_codigo',
            'label' => 'lang:records_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'records_tipo_descripcion',
            'label' => 'lang:records_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'records_tipo_abreviatura',
            'label' => 'lang:records_tipo_abreviatura',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[2]'
        ),
        array(
            'field' => 'records_tipo_tipo',
            'label' => 'lang:records_tipo_tipo',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'records_tipo_clasificacion',
            'label' => 'lang:records_tipo_clasificacion',
            'rules' => 'required|xss_clean|max_length[1]'
        ),
        array(
            'field' => 'records_tipo_peso',
            'label' => 'lang:records_tipo_peso',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'records_tipo_protected',
            'label' => 'lang:records_tipo_protected',
            'rules' => 'required|is_bool|xss_clean'
        )
    )
);
?>