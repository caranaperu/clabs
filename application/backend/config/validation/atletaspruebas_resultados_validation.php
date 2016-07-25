<?php

$config['v_atletaspruebas_resultados'] = array(
    'getAtletasPruebasResultados' => array(
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updAtletasPruebasResultados' => array(
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
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
            'field' => 'apppruebas_multiple',
            'label' => 'lang:apppruebas_multiple',
            'rules' => 'is_bool|xss_clean'
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
            'field' => 'atletas_resultados_resultado',
            'label' => 'lang:atletas_resultados_resultado',
            'rules' => 'required|xss_clean|max_length[12]'
        ),
        array(
            'field' => 'atletas_resultados_puesto',
            'label' => 'lang:atletas_resultados_puesto',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[3]'
        ),
        array(
            'field' => 'atletas_resultados_puntos',
            'label' => 'lang:atletas_resultados_puntos',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[4]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delAtletasPruebasResultados' => array(
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addAtletasPruebasResultados' => array(
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
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
            'field' => 'apppruebas_multiple',
            'label' => 'lang:apppruebas_multiple',
            'rules' => 'is_bool|xss_clean'
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
            'field' => 'atletas_resultados_resultado',
            'label' => 'lang:atletas_resultados_resultado',
            'rules' => 'required|xss_clean|max_length[12]'
        ),
        array(
            'field' => 'atletas_resultados_puesto',
            'label' => 'lang:atletas_resultados_puesto',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[3]'
        ),
        array(
            'field' => 'atletas_resultados_puntos',
            'label' => 'lang:atletas_resultados_puntos',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[4]'
        )
    )
);
?>