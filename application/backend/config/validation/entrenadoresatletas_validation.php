<?php

$config['v_entrenadoresatletas'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getEntrenadoresAtletas' => array(
        array(
            'field' => 'entrenadoresatletas_id',
            'label' => 'lang:entrenadoresatletas_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updEntrenadoresAtletas' => array(
        array(
            'field' => 'entrenadoresatletas_id',
            'label' => 'lang:entrenadoresatletas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'entrenadoresatletas_desde',
            'label' => 'lang:entrenadoresatletas_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'entrenadoresatletas_hasta',
            'label' => 'lang:entrenadoresatletas_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[entrenadoresatletas_desde]'
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
    'delEntrenadoresAtletas' => array(
        array(
            'field' => 'entrenadoresatletas_id',
            'label' => 'lang:entrenadoresatletas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addEntrenadoresAtletas' => array(
        array(
            'field' => 'entrenadores_codigo',
            'label' => 'lang:entrenadores_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'entrenadoresatletas_desde',
            'label' => 'lang:entrenadoresatletas_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'entrenadoresatletas_hasta',
            'label' => 'lang:entrenadoresatletas_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[entrenadoresatletas_desde]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>