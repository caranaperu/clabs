<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las records de diversa indole  sean mundiales,nacionales,etc
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RecordsModel.php 307 2014-07-16 02:17:13Z aranape $
 * @history ''
 *
 * $Date: 2014-07-15 21:17:13 -0500 (mar, 15 jul 2014) $
 * $Rev: 307 $
 */
class RecordsModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $records_id;
    protected $records_tipo_codigo;
    protected $atletas_resultados_id;
    protected $categorias_codigo;
    protected $records_id_origen;
    protected $records_protected;


    /**
     * Setea el id unico de la relacion entrenadores-atletas
     *
     * @param integer $records_id unico de la relacion entrenadores-atletas
     */
    public function set_records_id($records_id) {
        $this->records_id = $records_id;
        $this->setId($records_id);
    }

    /**
     * @return integer retorna el id unico de la relacion entrenadores-atletas
     */
    public function get_records_id() {
        return $this->records_id;
    }

    /**
     * Setea el codigo del tipo de record digase
     * olimpico,regional,nacional,etc.
     *
     * @param string $records_tipo_codigo codigo del tipo de record
     */
    public function set_records_tipo_codigo($records_tipo_codigo) {
        $this->records_tipo_codigo = $records_tipo_codigo;
    }

    /**
     *
     * @return string con el codigo del tipo de record
     */
    public function get_records_tipo_codigo() {
        return $this->records_tipo_codigo;
    }

    /**
     * El id de la relacion atleta/resultado esta relacion permite
     * obtener la fecha,lugar, atleta, marca ,competencia, etc.
     *
     * @return integer con el id de la relacion prueba/competencia
     */
    public function get_atletas_resultados_id() {
        return $this->atletas_resultados_id;
    }

    /**
     * Setea id de la relacion atleta/resultado esta relacion permite
     * obtener la fecha,lugar, atleta, marca , competencia,etc.
     *
     * @param integer $atletas_resultados_id
     */
    public function set_atletas_resultados_id($atletas_resultados_id) {
        $this->atletas_resultados_id = $atletas_resultados_id;
    }

    /**
     *
     * @return string que representa el codigo de la categoria para la cual
     * sera valido este record.
     *
     */
    public function get_categorias_codigo() {
        return $this->categorias_codigo;
    }

    /**
     * Setea el codigo que  representa  la categoria para la cual
     * sera valido este record.
     *
     * @param string $categorias_codigo codigo que  representa  la categoria desde la cual
     * sera valido este record.
     */
    public function set_categorias_codigo($categorias_codigo) {
        $this->categorias_codigo = $categorias_codigo;
    }

    /**
     *
     * @return int el id del cual se origino este registro.
     */
    public function get_records_id_origen() {
        return $this->records_id_origen;
    }

    /**
     * Setea el id del registo de record que origino esta entrada , esto se da en el
     * caso que digamos se ingrese un record de tipo mundial para mayores y este
     * genere automaticamente los de menor peso , como son el regional y el
     * nacional , en dicho caso este campo apuntara al id del registro padre.
     *
     * @param type $records_id_origen el id del cual se origino este registro.
     */
    public function set_records_id_origen($records_id_origen) {
        $this->records_id_origen = $records_id_origen;
    }

    /**
     *
     * @return boolean true si el registro no puede modificarse o eliminarse
     */
    public function get_records_protected() {
        return $this->records_protected;
    }

    /**
     * Se indica si un registro estara o no protegido de cualquier operacion
     * CRUD.
     *
     * @param boolean $records_protected  true si el registro esta protegido.
     */
    public function set_records_protected($records_protected) {
        if ($records_protected !== 'true' && $records_protected !== 'TRUE' &&
                $records_protected !== TRUE && $records_protected != 't' &&
                $records_protected != 'T' && $records_protected != '1') {
            $this->records_protected = 'false';
        } else {
            $this->records_protected = 'true';
        }
    }


    public function &getPKAsArray() {
        $pk['records_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>