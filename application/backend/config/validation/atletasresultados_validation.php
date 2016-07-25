<?php

$config['v_atletasresultados'] = array(
    'getAtletasResultados' => array(
        array(
            'field' => 'atletas_resultados_id',
            'label' => 'lang:atletas_resultados_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updAtletasResultados' => array(
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
            'field' => 'competencias_pruebas_id',
            'label' => 'lang:competencias_pruebas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'atletas_resultados_resultado',
            'label' => 'lang:atletas_resultados_resultado',
            'rules' => 'required|xss_clean|max_length[12]'
        ),
        array(
            'field' => 'atletas_resultados_viento',
            'label' => 'lang:atletas_resultados_viento',
            'rules' => 'decimal|xss_clean'
        ),
        array(
            'field' => 'atletas_resultados_puesto',
            'label' => 'lang:atletas_resultados_puesto',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[3]'
        ),
        array(
            'field' => 'atletas_resultados_puntos',
            'label' => 'lang:atletas_resultados_puesto',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[5]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delAtletasResultados' => array(
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
    'addAtletasResultados' => array(
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'competencias_pruebas_id',
            'label' => 'lang:competencias_pruebas_id',
            'rules' => 'required|integer|xss_clean'
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
            'field' => 'atletas_resultados_viento',
            'label' => 'lang:atletas_resultados_viento',
            'rules' => 'decimal|xss_clean'
        ),    
        array(
            'field' => 'atletas_resultados_puntos',
            'label' => 'lang:atletas_resultados_puesto',
            'rules' => 'integer|xss_clean|min_length[1]|max_length[5]'
        )
    )
);
?>