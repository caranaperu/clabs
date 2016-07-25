<?php

$config['v_competencias_pruebas'] = array(
    'getCompetenciasPruebas' => array(
        array(
            'field' => 'competencias_pruebas_id',
            'label' => 'lang:competencias_pruebas_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updCompetenciasPruebas' => array(
        array(
            'field' => 'competencias_pruebas_id',
            'label' => 'lang:competencias_pruebas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'competencias_pruebas_fecha',
            'label' => 'lang:competencias_pruebas_fecha',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_viento',
            'label' => 'lang:competencias_pruebas_viento',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_tipo_serie',
            'label' => 'lang:competencias_pruebas_tipo_serie',
            'rules' => 'required|xss_clean|exact_length[2]'
        ),
        array(
            'field' => 'competencias_pruebas_nro_serie',
            'label' => 'lang:competencias_pruebas_nro_serie',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[2]'
        ),
        array(
            'field' => 'competencias_pruebas_anemometro',
            'label' => 'lang:competencias_pruebas_anemometro',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_material_reglamentario',
            'label' => 'lang:competencias_pruebas_material_reglamentario',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_manual',
            'label' => 'lang:competencias_pruebas_manual',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_observaciones',
            'label' => 'lang:competencias_pruebas_observaciones',
            'rules' => 'xss_clean|max_length[250]'
        ),
        array(
            'field' => 'competencias_pruebas_origen_id',
            'label' => 'lang:competencias_pruebas_origen_id',
            'rules' => 'integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCompetenciasPruebas' => array(
        array(
            'field' => 'competencias_pruebas_id',
            'label' => 'lang:competencias_pruebas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCompetenciasPruebas' => array(
        array(
            'field' => 'competencias_codigo',
            'label' => 'lang:competencias_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'pruebas_codigo',
            'label' => 'lang:pruebas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'competencias_pruebas_fecha',
            'label' => 'lang:competencias_pruebas_fecha',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_viento',
            'label' => 'lang:competencias_pruebas_viento',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_tipo_serie',
            'label' => 'lang:competencias_pruebas_tipo_serie',
            'rules' => 'required|xss_clean|exact_length[2]'
        ),
        array(
            'field' => 'competencias_pruebas_nro_serie',
            'label' => 'lang:competencias_pruebas_nro_serie',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[2]'
        ),
        array(
            'field' => 'competencias_pruebas_anemometro',
            'label' => 'lang:competencias_pruebas_anemometro',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_material_reglamentario',
            'label' => 'lang:competencias_pruebas_material_reglamentario',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_manual',
            'label' => 'lang:competencias_pruebas_manual',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'competencias_pruebas_observaciones',
            'label' => 'lang:competencias_pruebas_observaciones',
            'rules' => 'xss_clean|max_length[250]'
        ),
        array(
            'field' => 'competencias_pruebas_origen_id',
            'label' => 'lang:competencias_pruebas_origen_id',
            'rules' => 'integer|xss_clean'
        )
    )
);
?>