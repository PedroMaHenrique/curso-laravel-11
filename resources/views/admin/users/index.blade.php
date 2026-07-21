@extends('admin.layouts.app')

@section('content')


    <h1>Usuários </h1>
    

    <a href="{{ route('users.create')}}">Adicionar Novo</a>

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
                <td>-</td>
               
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