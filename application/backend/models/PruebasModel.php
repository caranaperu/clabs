<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las pruebas atleticas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasModel.php 88 2014-03-25 15:14:07Z aranape $
 * @history ''
 *
 * $Date: 2014-03-25 10:14:07 -0500 (mar, 25 mar 2014) $
 * $Rev: 88 $
 */
class PruebasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $pruebas_codigo;
    protected $pruebas_descripcion;
    protected $pruebas_generica_codigo;
    protected $categorias_codigo;
    protected $pruebas_sexo;
    protected $pruebas_record_hasta;
    protected $pruebas_anotaciones;
    protected $pruebas_protected;

    /**
     * Setea el codigo de la prueba
     *
     * @param string $pruebas_codigo codigo unico de la prueba
     */
    public function set_pruebas_codigo($pruebas_codigo) {
        $this->pruebas_codigo = $pruebas_codigo;
        $this->setId($pruebas_codigo);
    }

    /**
     * @return string retorna el codigo unico de la prueba
     */
    public function get_pruebas_codigo() {
        return $this->pruebas_codigo;
    }

    /**
     * Setea la descrpcion de la prueba
     *
     * @param string $paises_descripcion la descrpcion de la prueba
     */
    public function set_pruebas_descripcion($pruebas_descripcion) {
        $this->pruebas_descripcion = $pruebas_descripcion;
    }

    /**
     *
     * @return string la descripcion de la prueba
     */
    public function get_pruebas_descripcion() {
        return $this->pruebas_descripcion;
    }

    /**
     * Setea el codigo generico de la prueba , este es un codigo
     * agrupador , digamos todas las modalidades de 100 metros con vallas (menores,mayores)
     * masculino,femenino, etc deberan tener un codigo generico unico que identifique a cada prueba
     * como 100 metros con vallas (ejemplo para femenino)
     *
     * @param string $pruebas_generica_codigo codigo generico
     */
    public function set_pruebas_generica_codigo($pruebas_generica_codigo) {
        $this->pruebas_generica_codigo = $pruebas_generica_codigo;
    }

    /**
     * Retorna el codigo generico de la prueba.
     *
     * @return string con el codigo generico
     */
    public function get_pruebas_generica_codigo() {
        return $this->pruebas_generica_codigo;
    }


    /**
     * Retorna la categoria de la prueba  digase mayor , juvenil , etc
     *
     * @return string con la categoria de la prueba
     */
    public function get_categorias_codigo() {
        return $this->categorias_codigo;
    }

    /**
     * Setea la categoria de la prueba  digase mayor , juvenil , etc
     *
     * @param string $categorias_codigo la categoria
     */
    public function set_categorias_codigo($categorias_codigo) {
        $this->categorias_codigo = $categorias_codigo;
    }

    /**
     * Retorna el sexo , el cual solo puede ser
     * 'F' - Femenino
     * 'M' - Masculino
     * 'A' - Ambos
     *
     * @return character con el sexo
     */
    public function get_pruebas_sexo() {
        return $this->pruebas_sexo;
    }

    /**
     * Setea el sexo , el cual solo puede ser
     * 'F' - Femenino
     * 'M' - Masculino
     * 'A' - Ambos
     *
     * @param type $pruebas_sexo
     */
    public function set_pruebas_sexo($pruebas_sexo) {
        $pruebas_sexo_u = strtoupper($pruebas_sexo);

        if ($pruebas_sexo_u != 'F' && $pruebas_sexo_u != 'M') {
            $this->pruebas_sexo = 'M';
        } else {
            $this->pruebas_sexo = $pruebas_sexo_u;
        }
    }

    /**
     * Retorna hasta que categoria de atleta (menor,mayor,etc) es
     * valida la prueba.
     *
     * @return string con el codigo de la categoria de atleta.
     */
    public function get_pruebas_record_hasta() {
        return $this->pruebas_record_hasta;
    }

    /**
     * Setea hasta que categoria de atleta (menor,mayor,etc) es
     * valida la prueba.
     *
     * @param string $pruebas_record_hasta con el codigo de la categoria de atleta.
     */
    public function set_pruebas_record_hasta($pruebas_record_hasta) {
        $this->pruebas_record_hasta = $pruebas_record_hasta;
    }

    /**
     *
     * @return string con las anotaciones
     */
    public function get_pruebas_anotaciones() {
        return $this->pruebas_anotaciones;
    }

    /**
     * Setea las anotaciones
     * @param string $pruebas_anotaciones
     */
    public function set_pruebas_anotaciones($pruebas_anotaciones) {
        $this->pruebas_anotaciones = $pruebas_anotaciones;
    }

        /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_pruebas_protected() {
        return $this->pruebas_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $categorias_protected
     */
    public function set_pruebas_protected($pruebas_protected) {
        $this->pruebas_protected = $pruebas_protected;
    }

    public function &getPKAsArray() {
        $pk['pruebas_codigo'] = $this->getId();
        return $pk;
    }

}

?>