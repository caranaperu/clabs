<?php

$config['v_competencia_tipo'] = array(
    'getCompetenciaTipo' => array(
        array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updCompetenciaTipo' => array(
        array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'competencia_tipo_descripcion',
            'label' => 'lang:competencia_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCompetenciaTipo' => array(
        array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCompetenciaTipo' => array(
              array(
            'field' => 'competencia_tipo_codigo',
            'label' => 'lang:competencia_tipo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'competencia_tipo_descripcion',
            'label' => 'lang:competencia_tipo_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        )
    )
);
?>