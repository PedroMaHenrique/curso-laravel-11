@extends('admin.layouts.app')

@section('title', 'listagem dos usuários')

@show_source

@section('content')


    <h1>Usuários </h1>

    <a href="{{ route('users.create')}}">Adicionar Novo</a>
    
    <x-alert/>
    
    <table>
        <thead>
            <tr>
                <th>Nome</th>
                <th>E-mail</th>
                <th>Ações</th>
            </tr>
        </thead>
        <tbody>
            @forelse($users as $user)
            <tr>
                <td>{{ $user->name}}</td>
                <td>{{ $user->email}}</td>
                <td>
                    <a href="{{ route('users.edit', $user->id) }} ">Edit</a>
                </td>
               
            </tr>
            @empty
            <tr>
                <td colspan="100"> Nenhum Usuário no banco</td>
            </tr>



            @endforelse
        </tbody>
    </table>
    {{$users->links() }}


@endsection