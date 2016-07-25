<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Modelo  para definir los paises donde se realizan las
     * competencias
     *
     * @author  $Author: aranape $
     * @since   06-FEB-2013
     * @version $Id: PaisesModel.php 279 2014-06-30 02:14:51Z aranape $
     * @history ''
     *
     * $Date: 2014-06-29 21:14:51 -0500 (dom, 29 jun 2014) $
     * $Rev: 279 $
     */
    class PaisesModel extends \app\common\model\TSLAppCommonBaseModel {

        protected $paises_codigo;
        protected $paises_descripcion;
        protected $paises_entidad;
        protected $regiones_codigo;
        protected $paises_use_apm;
        protected $paises_use_docid;

        /**
         * Setea el codigo unico del pais.
         *
         * @param string $paises_codigo codigo  unico del pais
         */
        public function set_paises_codigo($paises_codigo) {
            $this->paises_codigo = $paises_codigo;
            $this->setId($paises_codigo);
        }

        /**
         * @return string retorna el codigo unico del pais.
         */
        public function get_paises_codigo() {
            return $this->paises_codigo;
        }

        /**
         * Setea el nombre del pais.
         *
         * @param string $paises_descripcion nombre del pais
         */
        public function set_paises_descripcion($paises_descripcion) {
            $this->paises_descripcion = $paises_descripcion;
        }

        /**
         *
         * @return string con el nombre del pais
         */
        public function get_paises_descripcion() {
            return $this->paises_descripcion;
        }

        /**
         * Indica si el pais es el pais de la entidad que
         * usa el sistema.
         *
         * @return string true si es false si no lo es
         */
        public function get_paises_entidad() {
            return $this->paises_entidad;
        }

        /**
         * Setea si el pais es de la entidad usuaria
         *
         * @param mixed $paises_entidad indicara si el pais es de
         *                              la entidad usuaria, los posibles valores validos son 'TRUE',
         *                              'FALSE','true','false','t'.'f','T','F','1','0' o true , false
         */
        public function set_paises_entidad($paises_entidad) {
            if ($paises_entidad !== 'true' && $paises_entidad !== 'TRUE' &&
                $paises_entidad !== TRUE && $paises_entidad != 't' &&
                $paises_entidad != 'T' && $paises_entidad != '1'
            ) {
                $this->paises_entidad = 'false';
            } else {
                $this->paises_entidad = 'true';
            }
        }

        /**
         * Retorna el codigo de la region a la que pertenece el pais.
         *
         * @return string con el codigo de la region
         */
        public function get_regiones_codigo() {
            return $this->regiones_codigo;
        }

        /**
         * Setea el codigo de la region a la que pertenece el pais.
         *
         * @param string $regiones_codigo
         */
        public function set_regiones_codigo($regiones_codigo) {
            $this->regiones_codigo = $regiones_codigo;
        }

        /**
         * Dado que no todos los paises usan apellido materno , aqui se especifica
         * si el pais soporta o no dicho apellido.
         *
         * @param boolean $paises_use_apm true/false si soporta apellido materno
         */
        public function set_paises_use_apm($paises_use_apm) {
            $this->paises_use_apm = $paises_use_apm;
        }

        /**
         * Retorna si un pais soporta apellido materno.
         *
         * @return boolean true si soporta apellido materno.
         */
        public function get_paises_use_apm() {
            return $this->paises_use_apm;
        }

        /**
         * Se indicara si para este pais se soportara documento de identidad.
         *
         * @param boolean $paises_use_docid true/false si soporta doc. de identidad
         */
        public function set_paises_use_docid($paises_use_docid) {
            $this->paises_use_docid = $paises_use_docid;
        }

        /**
         * Retorna si en el pais se obliga a indicar documento de identidad.
         *
         * @return boolean true si soporta doc. de identidad.
         */
        public function get_paises_use_docid() {
            return $this->paises_use_docid;
        }

        public function &getPKAsArray() {
            $pk['paises_codigo'] = $this->getId();

            return $pk;
        }

    }

?>